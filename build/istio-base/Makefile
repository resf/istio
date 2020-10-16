VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )

NAME ?= istio-distroless
TAG ?= $(VERSION)

prepare: sync-docker-base
	@echo ::set-output name=image::$(NAME):$(TAG)
	@echo ::set-output name=build_args::VERSION=$(VERSION)

sync-docker-base:
	wget -O Dockerfile.istio-base https://raw.githubusercontent.com/istio/istio/$(VERSION)/docker/Dockerfile.base