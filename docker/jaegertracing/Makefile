VERSION = $(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
HUB = querycapistio
NAME = all-in-one
TARGET_PLATFORM = linux/arm64,linux/amd64

build: build-ui
	docker buildx build \
		--push \
		--platform $(TARGET_PLATFORM) \
		--build-arg VERSION=$(VERSION) \
		--tag $(HUB)/$(NAME):$(VERSION) \
		--file Dockerfile.$(NAME) .

build-ui:
	rm -rf jaeger-ui && git clone --depth=1 https://github.com/jaegertracing/jaeger-ui
	cd jaeger-ui && yarn install --frozen-lockfile && cd packages/jaeger-ui && yarn build

version:
	@echo "VERSION: $(VERSION)"