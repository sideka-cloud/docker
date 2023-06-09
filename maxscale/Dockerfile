# Base image using rockylinux 8
FROM rockylinux:8

# Maxscale version using 6.4
ENV MXS_VERSION=6.4

# Add MariaDB Enterprise Repo
RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | \
    bash -s -- --mariadb-maxscale-version=${MXS_VERSION} --apply

# Update System
RUN dnf -y install epel-release && dnf -y upgrade

# Install Some Basic Dependencies & MaxScale
RUN dnf clean expire-cache && \
    dnf -y install bind-utils \
    findutils less maxscale monit \
    nano ncurses net-tools openssl \
    procps-ng rsyslog tini wget

# default environment variable
ENV MAX_THREADS=4 \
    MAX_USER="maxscale_user" \
    MAX_PASS="maxscale_pass" \
    ENABLE_ROOT_USER=0 \
    ROUTER_PORT=3306 \ 
    SPLITTER_PORT=3307 \
    API_PORT=8989 \
    CONNECTION_TIMEOUT=600s \
    PERSIST_POOLMAX=0 \
    PERSIST_MAXTIME=30m \
    BACKEND_SERVER_LIST="server1 server2 server3" \
    BACKEND_SERVER_PORT="3306" \
    USE_SQL_VARIABLES_IN="all"

# Copy Files To Image
COPY config/maxscale.cnf /etc/
COPY config/monit.d/ /etc/monit.d/
COPY scripts/maxscale-start \
    scripts/maxscale-stop \
    scripts/maxscale-restart \
    /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start \
    /usr/bin/maxscale-stop \
    /usr/bin/maxscale-restart

# Expose MariaDB Port
EXPOSE $SPLITTER_PORT $ROUTER_PORT $API_PORT

# Create Persistent Volume
VOLUME ["/var/lib/maxscale"]

# Copy Entrypoint To Image
COPY scripts/docker-entrypoint.sh /usr/bin/

# Make Entrypoint Executable & Create Legacy Symlink
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Clean System & Reduce Size
RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

# Start Up
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I
