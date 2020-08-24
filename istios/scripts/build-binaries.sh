#!/bin/bash

set -eux

if [[ ! -d .tmp/istio ]]; then
  git clone https://github.com/istio/istio .tmp/istio
fi

cd .tmp/istio || exit

VERSION=${VERSION}
HUB=${HUB}

git checkout ${VERSION}

docker run \
  -v ${PWD}/../../bin:/tmp/bin \
  -v ${PWD}/../../scripts:/tmp/scripts \
  -v ${PWD}:/go/src/istio.io/istio \
  --workdir /go/src/istio.io/istio \
  golang:1.15 /tmp/scripts/gobuild.sh
