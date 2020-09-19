VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
HUB=querycapistio
IMAGE=${HUB}/kiali:${VERSION}

build:
	docker buildx build \
		--push \
		--platform linux/arm64,linux/amd64 \
		--build-arg VERSION=${VERSION} \
		--tag ${IMAGE} \
		--file Dockerfile .

version:
	@echo "VERSION: $(VERSION)"

sync:
	cd ../_sync && make -e IMAGE=${IMAGE} sync-image