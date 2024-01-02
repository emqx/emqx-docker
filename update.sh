#!/usr/bin/env bash

set -eou pipefail

VERSION="$1"
VERSION_DIR=$(echo "$VERSION" | cut -d '.' -f 1,2 -)

AMD64_SHA256=$(curl -sSL https://github.com/emqx/emqx/releases/download/v${VERSION}/emqx-${VERSION}-debian11-amd64.tar.gz.sha256)
ARM64_SHA256=$(curl -sSL https://github.com/emqx/emqx/releases/download/v${VERSION}/emqx-${VERSION}-debian11-arm64.tar.gz.sha256)

sed -i'' -e "s/EMQX_VERSION=.*/EMQX_VERSION=${VERSION}/" $VERSION_DIR/Dockerfile
sed -i'' -e "s/AMD64_SHA256=.*/AMD64_SHA256=${AMD64_SHA256}/" $VERSION_DIR/Dockerfile
sed -i'' -e "s/ARM64_SHA256=.*/ARM64_SHA256=${ARM64_SHA256}/" $VERSION_DIR/Dockerfile
