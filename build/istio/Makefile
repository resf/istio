VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
ENVOY_VERSION=$(shell docker inspect $(shell docker create istio/proxyv2:$(VERSION)) --format "{{ json .Config.Env }}" | sed -e 's/.*"ISTIO_META_ISTIO_PROXY_SHA=\([^"]*\)".*/\1/g')
HUB = querycapistio
NAME ?= operator

BASE_DISTRIBUTION = $(HUB)/base:$(shell git rev-parse --short HEAD)

TAG = $(VERSION)
IMAGE = $(HUB)/$(NAME):$(TAG)

image:
	@echo $(IMAGE)

build: build-docker-base
	$(MAKE) -f ../Makefile buildx TAGS=$(IMAGE) DOCKERFILE=Dockerfile.$(NAME) BUILD_ARGS="VERSION=$(VERSION) ENVOY_VERSION=$(ENVOY_VERSION) BASE_DISTRIBUTION=$(BASE_DISTRIBUTION)"

sync-docker-base:
	wget -O base.Dockerfile https://raw.githubusercontent.com/istio/istio/$(VERSION)/docker/Dockerfile.base

build-docker-base: sync-docker-base
	$(MAKE) -f ../Makefile buildx TAGS=$(BASE_DISTRIBUTION) DOCKERFILE=base.Dockerfile

version:
	@echo "VERSION: $(VERSION)"
	@echo "ENVOY_VERSION: $(ENVOY_VERSION)"
