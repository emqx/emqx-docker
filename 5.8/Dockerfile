FROM debian:12-slim

ENV EMQX_VERSION=5.8.7
ENV AMD64_SHA256=a4ac9db115ab06e3d8dfdeefa71dbfb96ac039279e55df98575e14ba34ed2b1d
ENV ARM64_SHA256=6efd454c0a0ef0d01ad22f804c91e4502287834de0f5cd3c70381daed43d398f
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates procps curl; \
    arch=$(dpkg --print-architecture); \
    if [ ${arch} = "amd64" ]; then sha256="$AMD64_SHA256"; fi; \
    if [ ${arch} = "arm64" ]; then sha256="$ARM64_SHA256"; fi; \
    . /etc/os-release; \
    pkg="emqx-${EMQX_VERSION}-${ID}${VERSION_ID}-${arch}.tar.gz"; \
    curl -f -O -L https://www.emqx.com/en/downloads/broker/v${EMQX_VERSION}/${pkg}; \
    echo "$sha256 *$pkg" | sha256sum -c; \
    mkdir /opt/emqx; \
    tar zxf $pkg -C /opt/emqx; \
    find /opt/emqx -name 'swagger*.js.map' -exec rm {} +; \
    ln -s /opt/emqx/bin/* /usr/local/bin/; \
    groupadd -r -g 1000 emqx; \
    useradd -r -m -u 1000 -g emqx emqx; \
    chown -R emqx:emqx /opt/emqx; \
    rm -f $pkg; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/emqx

USER emqx

VOLUME ["/opt/emqx/log", "/opt/emqx/data"]

# emqx will occupy these port:
# - 1883 port for MQTT
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8883 port for MQTT(SSL)
# - 18083 for dashboard and API
# - 4370 default Erlang distribution port
# - 5369 for backplain gen_rpc
EXPOSE 1883 8083 8084 8883 18083 4370 5369

COPY docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["/opt/emqx/bin/emqx", "foreground"]
