VERSION=$(shell cat .version)
HUB=querycapjaegertracing

build:
	docker buildx build \
		--push \
		--platform linux/arm64,linux/amd64 \
		--build-arg VERSION=${VERSION} \
		--tag ${HUB}/all-in-one:${VERSION} \
		--file Dockerfile .