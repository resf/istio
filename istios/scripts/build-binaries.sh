#!/bin/bash

if [[ ! -d .tmp/istio ]]; then
    git clone https://github.com/istio/istio .tmp/istio
fi

cd .tmp/istio || exit

VERSION=${VERSION}
HUB=${HUB}

git checkout ${VERSION}

BINARIES="./pilot/cmd/pilot-discovery ./pilot/cmd/pilot-agent ./operator/cmd/operator"

docker run \
    -v ${PWD}/../../bin:/tmp/istio \
    -v ${PWD}:/go/src/github.com/istio/istio \
    --workdir /go/src/github.com/istio/istio \
    golang:1.14 \
    sh -c "STATIC=0 GOOS=linux GOARCH=arm64 LDFLAGS='-extldflags -static -s -w' common/scripts/gobuild.sh /tmp/istio/ ${BINARIES}"