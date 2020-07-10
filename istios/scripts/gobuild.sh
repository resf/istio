#!/bin/bash

set -eux

GO111MODULE=on go get github.com/jteeuwen/go-bindata/go-bindata@6025e8de665b

./operator/scripts/create_assets_gen.sh

BINARIES="./pilot/cmd/pilot-discovery ./pilot/cmd/pilot-agent ./operator/cmd/operator"

sh -c "STATIC=0 GOOS=linux GOARCH=arm64 LDFLAGS='-extldflags -static -s -w' common/scripts/gobuild.sh /tmp/bin/ ${BINARIES}"
