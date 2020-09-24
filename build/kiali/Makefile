VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
NAME = kiali
HUB = querycapistio

TAG = $(VERSION)
IMAGE = $(HUB)/$(NAME):$(TAG)

image:
	@echo $(IMAGE)

build:
	$(MAKE) -f ../Makefile buildx TAGS=$(IMAGE) BUILD_ARGS=VERSION=$(VERSION) DOCKERFILE=Dockerfile.$(NAME)


