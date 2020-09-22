VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
NAME = kiali
HUB = querycapistio

build:
	$(MAKE) -f ../Makefile buildx TAGS=$(HUB)/$(NAME):$(VERSION) BUILD_ARGS=VERSION=$(VERSION) DOCKERFILE=Dockerfile.$(NAME)

version:
	@echo "VERSION: $(VERSION)"
