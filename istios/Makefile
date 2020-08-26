VERSION=$(shell cat .version)
ENVOY_VERSION=$(shell cat .envoy-version)
HUB=querycapistio

build:
	HUB=${HUB} VERSION=${VERSION} ENVOY_VERSION=${ENVOY_VERSION} docker buildx bake -f ./bake.hcl --push

build-binaries:
	HUB=${HUB} VERSION=${VERSION} ./scripts/build-binaries.sh

sync:
	cd ../_sync && make -e IMAGE=${HUB}/proxyv2:${VERSION} sync-image
	cd ../_sync && make -e IMAGE=${HUB}/pilot:${VERSION} sync-image
	cd ../_sync && make -e IMAGE=${HUB}/operator:${VERSION} sync-image