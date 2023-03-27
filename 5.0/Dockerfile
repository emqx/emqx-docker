FROM debian:11-slim

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates procps; \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r -g 1000 emqx; \
    useradd -r -m -u 1000 -g emqx emqx;

ENV EMQX_VERSION=5.0.21
ENV AMD64_SHA256=d83d435bfd49fc06cf9448de12ee76d383f9919fbb4d149545ccc246c903b78e
ENV ARM64_SHA256=29dc8a470c9d43069dbc0f640e9493a991516fa18e028930726e8a6c7e60afc6
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN set -eu; \
    arch=$(dpkg --print-architecture); \
    if [ ${arch} = "amd64" ]; then sha256="$AMD64_SHA256"; fi; \
    if [ ${arch} = "arm64" ]; then sha256="$ARM64_SHA256"; fi; \
    ID="$(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/\"//g')"; \
    VERSION_ID="$(sed -n '/^VERSION_ID=/p' /etc/os-release | sed -r 's/VERSION_ID=(.*)/\1/g' | sed 's/\"//g')"; \
    pkg="emqx-${EMQX_VERSION}-${ID}${VERSION_ID}-${arch}.tar.gz"; \
    curl -f -O -L https://www.emqx.com/en/downloads/broker/v${EMQX_VERSION}/${pkg} && \
    echo "$sha256 *$pkg" | sha256sum -c && \
    mkdir /opt/emqx && \
    tar zxf $pkg -C /opt/emqx && \
    chgrp -Rf emqx /opt/emqx && \
    chmod -Rf g+w /opt/emqx && \
    chown -Rf emqx /opt/emqx && \
    ln -s /opt/emqx/bin/* /usr/local/bin/ && \
    rm -f $pkg

WORKDIR /opt/emqx

USER emqx

VOLUME ["/opt/emqx/log", "/opt/emqx/data"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8883 port for MQTT(SSL)
# - 11883 port for internal MQTT/TCP
# - 18083 for dashboard and API
# - 4370 default Erlang distribution port
# - 5369 for backplain gen_rpc
EXPOSE 1883 8083 8084 8883 11883 18083 4370 5369

COPY docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["/opt/emqx/bin/emqx", "foreground"]
