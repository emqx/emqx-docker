FROM debian:11-slim

ENV EMQX_VERSION=5.3.2
ENV AMD64_SHA256=d5948d4171f57e77756dd6c9eeb745c39e391e75aad3798fce445f44f5690be0
ENV ARM64_SHA256=82b056bb1c1cd1f16e9d0719150fa8ac19c499d29563738bcd6984b3c395c6ac
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates procps curl; \
    arch=$(dpkg --print-architecture); \
    if [ ${arch} = "amd64" ]; then sha256="$AMD64_SHA256"; fi; \
    if [ ${arch} = "arm64" ]; then sha256="$ARM64_SHA256"; fi; \
    ID="$(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/\"//g')"; \
    VERSION_ID="$(sed -n '/^VERSION_ID=/p' /etc/os-release | sed -r 's/VERSION_ID=(.*)/\1/g' | sed 's/\"//g')"; \
    pkg="emqx-${EMQX_VERSION}-${ID}${VERSION_ID}-${arch}.tar.gz"; \
    curl -f -O -L https://www.emqx.com/en/downloads/broker/v${EMQX_VERSION}/${pkg}; \
    echo "$sha256 *$pkg" | sha256sum -c; \
    mkdir /opt/emqx; \
    tar zxf $pkg -C /opt/emqx; \
    find /opt/emqx -name 'swagger*.js.map' -exec rm {} +; \
    groupadd -r -g 1000 emqx; \
    useradd -r -m -u 1000 -g emqx emqx; \
    chgrp -Rf emqx /opt/emqx; \
    chmod -Rf g+w /opt/emqx; \
    chown -Rf emqx /opt/emqx; \
    ln -s /opt/emqx/bin/* /usr/local/bin/; \
    rm -f $pkg; \
    apt-get purge -y --auto-remove curl; \
    rm -rf /var/lib/apt/lists/*

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
