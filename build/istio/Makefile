VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )

DOCKERX_NAME ?= operator
DOCKERX_TAGS ?= $(VERSION)

BASE_DISTRIBUTION ?= default
ENVOY_VERSION ?= none
ifeq ($(BASE_DISTRIBUTION),distroless)
	DOCKERX_TAGS := $(DOCKERX_TAGS)-distroless
endif

ifeq ($(DOCKERX_NAME),proxyv2)
	ENVOY_VERSION := $(shell docker inspect $(shell docker create istio/proxyv2:$(VERSION)-distroless) --format "{{ json .Config.Env }}" | sed -e 's/.*"ISTIO_META_ISTIO_PROXY_SHA=\([^"]*\)".*/\1/g')
endif


DOCKERX_BUILD_ARGS ?= VERSION=$(VERSION) BASE_DISTRIBUTION=$(BASE_DISTRIBUTION) ENVOY_VERSION=$(ENVOY_VERSION)

include ../Makefile