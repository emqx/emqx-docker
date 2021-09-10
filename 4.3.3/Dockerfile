FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

ENV VERSION=4.3.3

RUN curl -fsSL https://repos.emqx.io/gpg.pub | apt-key add - \
    && add-apt-repository "deb https://repos.emqx.io/emqx-ce/deb/debian/ ./$(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y --no-install-recommends emqx="$VERSION" \
    && rm -rf /var/lib/apt/lists/*

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
