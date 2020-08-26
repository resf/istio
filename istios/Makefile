VERSION=$(shell cat .version)
ENVOY_VERSION=$(shell cat .envoy-version)

HUB=querycapistio
BASE_DISTRIBUTION=${HUB}/base:$(shell cat ../base/.version)

TARGET_PLATFORM=linux/arm64,linux/amd64

build.operator:
	IMAGE=operator $(MAKE) build-image

build.pilot:
	IMAGE=pilot $(MAKE) build-image

build.proxyv2:
	IMAGE=proxyv2 $(MAKE) build-image

sync.operator:
	cd ../_sync && make -e IMAGE=${HUB}/operator:${VERSION} sync-image

sync.pilot:
	cd ../_sync && make -e IMAGE=${HUB}/pilot:${VERSION} sync-image

sync.proxyv2:
	cd ../_sync && make -e IMAGE=${HUB}/proxyv2:${VERSION} sync-image

build-image:
	docker buildx build \
	--push \
	--platform=${TARGET_PLATFORM} \
	--build-arg BASE_DISTRIBUTION=${BASE_DISTRIBUTION} \
	--build-arg VERSION=${VERSION} \
	--build-arg ENVOY_VERSION=${ENVOY_VERSION} \
	--tag "${HUB}/${IMAGE}:${VERSION}" \
	--file ${IMAGE}.Dockerfile .
