#!/bin/bash

set -e

# use .sh file to create a .sql file, which will be parsed afterwards due to alphabetical sorting

config_file="/docker-entrypoint-initdb.d/init_maxscale_user.sql"

# start config file creation

cat <<EOF > $config_file
CREATE USER '$MAXSCALE_USER'@'%' identified by '$MAXSCALE_PASS';
GRANT SELECT ON mysql.user TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.roles_mapping TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.db TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.tables_priv TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.columns_priv TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.procs_priv TO '$MAXSCALE_USER'@'%';
GRANT SELECT ON mysql.proxies_priv TO '$MAXSCALE_USER'@'%';
GRANT REPLICATION CLIENT ON *.* TO '$MAXSCALE_USER'@'%';
GRANT SHOW DATABASES ON *.* TO '$MAXSCALE_USER'@'%';
FLUSH PRIVILEGES;
EOF
