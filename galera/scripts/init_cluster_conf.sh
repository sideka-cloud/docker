#!/bin/bash

set -e

# set gcomm string with cluster_members via ENV by default
CLUSTER_ADDRESS="gcomm://$CLUSTER_MEMBERS?pc.wait_prim=no"

# use dns service discovery to find other members when in service mode
# and set/override cluster_members provided by ENV
if [ -n "$DB_SERVICE_NAME" ]; then

  # check, if have to enable bootstrapping, if only/first node live
  if [ `getent hosts tasks.$DB_SERVICE_NAME|wc -l` = 1 ] ;then
    # bootstrapping gets enabled by empty gcomm string
    CLUSTER_ADDRESS="gcomm://"
  else
    # fetch IPs of service members
    CLUSTER_MEMBERS=`getent hosts tasks.$DB_SERVICE_NAME|awk '{print $1}'|tr '\n' ','`
    # set gcomm string with found service members
    CLUSTER_ADDRESS="gcomm://$CLUSTER_MEMBERS?pc.wait_prim=no"
  fi
fi


# create a galera config
config_file="/etc/mysql/conf.d/galera.cnf"

cat <<EOF > $config_file
# Node specifics
[mysqld]
innodb_large_prefix = ON
key-buffer-size = 32M
max-heap-table-size = 64M
max-allowed-packet = 32M
tmp-table-size = 64M
max_connections = 150
thread-cache-size = 50
thread_stack=2M
open-files-limit = 150000
table-definition-cache = 4096
table-open-cache = 8192
innodb-log-files-in-group = 2
innodb-log-file-size = 1G
innodb-file-per-table = 1
innodb-buffer-pool-size = 256M
innodb-buffer-pool-instances = 8
innodb-io-capacity = 5000
innodb-read-io-threads = 32
innodb-write-io-threads = 16
innodb_doublewrite = 1
innodb_adaptive_hash_index = False
transaction_isolation = READ-COMMITTED
innodb-thread-concurrency = 64
wait_timeout = 300
sort_buffer_size = 8M
read_buffer_size = 8M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 32M
query_cache_size= 32M
skip-name-resolve

# next 3 params disabled for the moment, since they are not mandatory and get changed with each new instance.
# they also triggered problems when trying to persist data with a backup service, since also the config has to be
# persisted, but HOSTNAME changes at container startup.
#wsrep-node-name = $HOSTNAME
#wsrep-sst-receive-address = $HOSTNAME
#wsrep-node-incoming-address = $HOSTNAME

# Cluster settings
wsrep-on=ON
wsrep-cluster-name = "$CLUSTER_NAME"
wsrep-cluster-address = $CLUSTER_ADDRESS
wsrep-provider = /usr/lib/galera/libgalera_smm.so
wsrep-provider-options = "gcache.size=512M;gcache.page_size=256M;gcache.recover = yes;debug=no"
wsrep-sst-auth = "$GALERA_USER:$GALERA_PASS"
wsrep_sst_method = rsync
binlog-format = row
default-storage-engine = InnoDB
innodb-doublewrite = 1
innodb-autoinc-lock-mode = 2
innodb-flush-log-at-trx-commit = 2
EOF
