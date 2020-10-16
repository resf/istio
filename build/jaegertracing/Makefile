VERSION = $(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )

NAME ?= all-in-one
TAG ?= $(VERSION)

prepare: setup
	@echo ::set-output name=image::$(NAME):$(TAG)
	@echo ::set-output name=build_args::VERSION=$(VERSION)

setup:
	docker buildx build --push --build-arg VERSION=$(VERSION) -t localhost:5000/src:$(VERSION) -f ./src.Dockerfile .