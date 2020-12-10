#!bin/bash

ISIO_BRANCE=release-1.8

git clone --depth=1 -b ${ISIO_BRANCE} https://github.com/istio/istio.git /tmp/istio

rm -rf charts/istio-operator/templates/*
rm -rf charts/istio-operator/crds/*

cp -r /tmp/istio/manifests/charts/istio-operator/templates/* charts/istio-operator/templates/
cp -r /tmp/istio/manifests/charts/istio-operator/crds/* charts/istio-operator/crds/
rm charts/istio-operator/templates/namespace.yaml

rm -rf /tmp/istio