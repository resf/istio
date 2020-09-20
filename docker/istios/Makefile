VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
ENVOY_VERSION=$(shell docker inspect $(shell docker create istio/proxyv2:$(VERSION)) --format "{{ json .Config.Env }}" | sed -e 's/.*"ISTIO_META_ISTIO_PROXY_SHA=\([^"]*\)".*/\1/g')
HUB = querycapistio
NAME ?= operator
TARGET_PLATFORM = linux/arm64,linux/amd64

build:
	docker buildx build \
	--push \
	--platform=$(TARGET_PLATFORM) \
	--build-arg VERSION=$(VERSION) \
	--build-arg ENVOY_VERSION=$(ENVOY_VERSION) \
	--build-arg BASE_DISTRIBUTION=$(HUB)/base:$(VERSION) \
	--tag "$(HUB)/$(NAME):$(VERSION)" \
	--file Dockerfile.$(NAME) .

version:
	@echo "VERSION: $(VERSION)"
	@echo "ENVOY_VERSION: $(ENVOY_VERSION)"
