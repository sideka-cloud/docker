#!/bin/bash

function exitMaxScale {
    /usr/bin/monit unmonitor all
    /usr/bin/maxscale-stop
    /usr/bin/monit quit
}

rm -f /var/run/*.pid
rsyslogd

trap exitMaxScale SIGTERM


set -e

# if service discovery was activated, we overwrite the BACKEND_SERVER_LIST with the
# results of DNS service lookup
if [ -n "$DB_SERVICE_NAME" ]; then
  BACKEND_SERVER_LIST=`getent hosts tasks.$DB_SERVICE_NAME|awk '{print $1}'|tr '\n' ' '`
fi

# We break our IP list into array
IFS=', ' read -r -a backend_servers <<< "$BACKEND_SERVER_LIST"

config_file="/etc/maxscale.cnf"

# start config file creation

cat <<EOF > $config_file
[maxscale]
threads=$MAX_THREADS

[Galera-RoundRobin-Service]
type=service
router=readconnroute
router_options=synced
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
password=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER

[Galera-RoundRobin-Listener]
type=listener
service=Galera-RoundRobin-Service
protocol=MariaDBClient
port=$ROUTER_PORT

[Galera-ReadWrite-Service]
type=service
router=readwritesplit
servers=${BACKEND_SERVER_LIST// /,}
connection_timeout=$CONNECTION_TIMEOUT
user=$MAX_USER
password=$MAX_PASS
enable_root_user=$ENABLE_ROOT_USER
use_sql_variables_in=$USE_SQL_VARIABLES_IN

[Galera-ReadWrite-Listener]
type=listener
service=Galera-ReadWrite-Service
protocol=MariaDBClient
port=$SPLITTER_PORT

[Galera-Monitor]
type=monitor
module=galeramon
servers=${BACKEND_SERVER_LIST// /,}
disable_master_failback=1
user=$MAX_USER
password=$MAX_PASS

# Start the Server block
EOF

# add the [server] block
for i in ${!backend_servers[@]}; do
cat <<EOF >> $config_file
[${backend_servers[$i]}]
type=server
address=${backend_servers[$i]}
port=$BACKEND_SERVER_PORT
protocol=MariaDBBackend
persistpoolmax=$PERSIST_POOLMAX
persistmaxtime=$PERSIST_MAXTIME

EOF

done

exec "$@" &

wait
