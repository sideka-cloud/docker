#!/bin/bash

set -e

# use .sh file to create a .sql file, which will be parsed afterwards due to alphabetical sorting
config_file="/docker-entrypoint-initdb.d/init_galera_user.sql"

# start config file creation

cat <<EOF > $config_file
GRANT ALL PRIVILEGES on *.* to '$GALERA_USER'@'%' identified by '$GALERA_PASS';
FLUSH PRIVILEGES;
EOF
