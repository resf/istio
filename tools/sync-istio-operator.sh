#!bin/bash

ISIO_BRANCE=release-1.8

git clone --depth=1 -b ${ISIO_BRANCE} https://github.com/istio/istio.git /tmp/istio

rm -rf charts/istio-operator

cp -r /tmp/istio/manifests/charts/istio-operator charts/istio-operator

rm -rf charts/istio-operator/files
rm -rf /tmp/istio