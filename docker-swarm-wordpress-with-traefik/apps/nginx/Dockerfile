FROM alpine:3

ARG VERSION=1.22

RUN set -ex && \
    #
    # Install shadow to create nginx user & group
    # with the same uid & gid as in wordpress image
    apk add --no-cache --virtual .build-deps shadow && \
    groupadd -g 1182 nginx && \
    useradd -u 1182 -g 1182 -c nginx -m -d /var/lib/nginx -s /sbin/nologin nginx && \
    #
    # Install nginx and cache purge module
    apk update && apk upgrade && \
    apk add --no-cache nginx nginx-mod-http-cache-purge && \
    apk add --no-cache nano bash nginx-mod-http-zip nginx-mod-http-geoip2 && \
    #
    # Cleanup
    apk del .build-deps && \
    rm -rf /var/www/localhost/ && \
    #
    # Create dir for fastcgi_cache
    mkdir -p /var/cache/nginx && \
    chown -R nginx.nginx /var/cache/nginx && \
    #
    # Create default pid dir
    mkdir -p /var/run/nginx && \
    #
    # Forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
