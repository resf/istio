VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
HUB = querycapistio
NAME = kiali
TARGET_PLATFORM = linux/arm64,linux/amd64

build:
	docker buildx build \
		--push \
		--platform $(TARGET_PLATFORM) \
		--build-arg VERSION=$(VERSION) \
		--tag $(HUB)/$(NAME):$(VERSION) \
		--file Dockerfile.$(NAME) .

version:
	@echo "VERSION: $(VERSION)"
