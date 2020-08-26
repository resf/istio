VERSION=$(shell cat .version)
HUB=querycapistio
IMAGE=${HUB}/all-in-one:${VERSION}

build:
	docker buildx build \
		--push \
		--platform linux/arm64,linux/amd64 \
		--build-arg VERSION=${VERSION} \
		--tag ${IMAGE} \
		--file Dockerfile .

sync:
	cd ../_sync && make -e IMAGE=${IMAGE} sync-image