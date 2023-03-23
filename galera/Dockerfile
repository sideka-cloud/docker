# base image using mariadb 10.10
FROM mariadb:10.10

# update system and install some basic toolkit
RUN apt update && apt upgrade -y && apt install iputils-ping nano net-tools -y \
    && rm -rf /var/lib/apt/lists/*

# copy enterpoint to image    
COPY scripts/ /docker-entrypoint-initdb.d/.

# touch and chown config files
RUN touch /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /etc/mysql/conf.d/galera.cnf \
    && chown mysql.mysql /docker-entrypoint-initdb.d/*.sql

# expose all cluster related ports
EXPOSE 3306 4444 4567 4568

# set defaults environment config
ENV GALERA_USER=supergalera \
    GALERA_PASS=supergalera \
    MAXSCALE_USER=maxscale_user \
    MAXSCALE_PASS=maxscale_pass \ 
    CLUSTER_NAME=docker_cluster \
    MYSQL_ALLOW_EMPTY_PASSWORD=1

# start up    
CMD ["mysqld"]
