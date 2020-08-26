VERSION=$(shell cat .version)
HUB=querycap

build:
	docker buildx build \
		--push \
		--platform linux/arm64,linux/amd64 \
		--build-arg VERSION=${VERSION} \
		--tag ${HUB}/kiali:${VERSION} \
		--file Dockerfile .