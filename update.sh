#!/usr/bin/env bash

set -eou pipefail

VERSION="$1"
VERSION_DIR=$(echo "$VERSION" | cut -d '.' -f 1,2 -)

AMD64_SHA256=$(curl -sSL https://github.com/emqx/emqx/releases/download/v${VERSION}/emqx-${VERSION}-debian13-amd64.tar.gz.sha256)
ARM64_SHA256=$(curl -sSL https://github.com/emqx/emqx/releases/download/v${VERSION}/emqx-${VERSION}-debian13-arm64.tar.gz.sha256)

sed -i.bak \
    -e "s/EMQX_VERSION=.*/EMQX_VERSION=${VERSION}/" \
    -e "s/AMD64_SHA256=.*/AMD64_SHA256=${AMD64_SHA256}/" \
    -e "s/ARM64_SHA256=.*/ARM64_SHA256=${ARM64_SHA256}/" \
    $VERSION_DIR/Dockerfile
rm -f $VERSION_DIR/Dockerfile.bak
