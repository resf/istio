VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )

DOCKERX_NAME ?= istio-distroless
DOCKERX_TAGS ?= $(VERSION)
DOCKERX_BUILD_ARGS ?= VERSION=$(VERSION)

include ../Makefile

sync-docker-base:
	wget -O Dockerfile.istio-base https://raw.githubusercontent.com/istio/istio/$(VERSION)/docker/Dockerfile.base