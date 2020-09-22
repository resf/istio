VERSION = $(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
HUB = querycapistio
NAME = all-in-one
TARGET_PLATFORM = linux/arm64,linux/amd64

build: build-ui
	$(MAKE) -f ../Makefile buildx \
		TAGS=$(HUB)/$(NAME):$(VERSION) \
		BUILD_ARGS="VERSION=$(VERSION) JAGGER_UI=$(HUB)/jagger-ui:$(VERSION)" \
		DOCKERFILE=Dockerfile.$(NAME)

build-ui:
	$(MAKE) -f ../Makefile buildx \
		TAGS=$(HUB)/jagger-ui:$(VERSION) \
		DOCKERFILE=jagger-ui.Dockerfile \
		TARGET_PLATFORM=linux/amd64 \
		BUILD_ARGS=VERSION=$(VERSION)

version:
	@echo "VERSION: $(VERSION)"