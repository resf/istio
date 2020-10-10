VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
ENVOY_VERSION=$(shell docker inspect $(shell docker create istio/proxyv2:$(VERSION)) --format "{{ json .Config.Env }}" | sed -e 's/.*"ISTIO_META_ISTIO_PROXY_SHA=\([^"]*\)".*/\1/g')
HUB = querycapistio
NAME ?= operator

TAG = $(VERSION)
IMAGE = $(HUB)/$(NAME):$(TAG)
GOMODCACHE=/tmp/.buildx-cache/gomodcache

image:
	@echo $(IMAGE) $(IMAGE)-distroless

build: prepare
	$(MAKE) -f ../Makefile buildx TAGS=$(IMAGE) DOCKERFILE=Dockerfile.$(NAME) BUILD_ARGS="VERSION=$(VERSION) ENVOY_VERSION=$(ENVOY_VERSION) BASE_DISTRIBUTION=default"
	$(MAKE) -f ../Makefile buildx TAGS=$(IMAGE)-distroless DOCKERFILE=Dockerfile.$(NAME) BUILD_ARGS="VERSION=$(VERSION) ENVOY_VERSION=$(ENVOY_VERSION) BASE_DISTRIBUTION=distroless"

prepare:
	docker run -e=GOPROXY=${GOPROXY} -v=$(GOMODCACHE):/go/pkg/mod golang:1.15 sh -c "git clone --depth=1 -b $(VERSION) https://github.com/istio/istio && cd istio && go mod download -x"

version:
	@echo "VERSION: $(VERSION)"
	@echo "ENVOY_VERSION: $(ENVOY_VERSION)"
