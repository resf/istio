VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
HUB = querycapistio
NAME ?= istio-distroless

TAG = $(VERSION)
IMAGE = $(HUB)/$(NAME):$(TAG)

image:
	@echo $(IMAGE)

build: sync-docker-base
	$(MAKE) -f ../Makefile buildx TAGS=$(IMAGE) DOCKERFILE=Dockerfile.$(NAME)

sync-docker-base:
	wget -O Dockerfile.istio-base https://raw.githubusercontent.com/istio/istio/$(VERSION)/docker/Dockerfile.base

version:
	@echo "VERSION: $(VERSION)"
