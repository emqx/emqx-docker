FROM debian:buster-slim

ENV EMQX_MAJOR 4.3
ENV EMQX_VERSION 4.3.5

RUN groupadd -r emqx && useradd -r -g emqx emqx

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    rm -rf /var/lib/apt/lists/*

RUN set -eu; \
# gpg: key C0B409463E640D53: public key "emqx team <support@emqx.io>" imported
    key='FC841BA637755CA8487B1E3CC0B409463E640D53'; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    mkdir -p /etc/apt/keyrings; \
    gpg --batch --export "$key" > /etc/apt/keyrings/emqx.gpg; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"

RUN set -eu; \
    echo "deb [signed-by=/etc/apt/keyrings/emqx.gpg] https://repos.emqx.io/emqx-ce/deb/debian/ ./buster stable" >> /etc/apt/sources.list.d/emqx.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends emqx="$EMQX_VERSION"; \
    rm -rf /var/lib/apt/lists/*

USER emqx

VOLUME ["/opt/emqx/log", "/opt/emqx/data"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8081 for mgmt API
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8883 port for MQTT(SSL)
# - 11883 port for internal MQTT/TCP
# - 18083 for dashboard
# - 4369 epmd (Erlang-distrbution port mapper daemon) listener (deprecated)
# - 4370 default Erlang distrbution port
# - 5369 for gen_rpc port mapping
# - 6369 6370 for distributed node
EXPOSE 1883 8081 8083 8084 8883 11883 18083 4369 4370 5369 6369 6370

COPY docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["emqx", "foreground"]
