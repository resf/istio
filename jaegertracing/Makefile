VERSION=$(shell cat .version)
HUB=querycapistio
IMAGE=${HUB}/all-in-one:${VERSION}

build: build-ui
	docker buildx build \
		--push \
		--platform linux/arm64,linux/amd64 \
		--build-arg VERSION=${VERSION} \
		--tag ${IMAGE} \
		--file Dockerfile .

build-ui:
	rm -rf jaeger-ui && git clone --depth=1 https://github.com/jaegertracing/jaeger-ui
	cd jaeger-ui && yarn install --frozen-lockfile && cd packages/jaeger-ui && yarn build

sync:
	cd ../_sync && make -e IMAGE=${IMAGE} sync-image