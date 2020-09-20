NAME = proxyv2
IMAGE = $(shell cat Dockerfile.$(NAME) | grep "^FROM " | sed -e "s/FROM //g" )
HUB = hub-dev.demo.querycap.com

echo:
	@echo $(IMAGE)

sync:
	docker buildx build \
    --push \
    --platform linux/arm64,linux/amd64 \
    --tag $(HUB)/$(IMAGE) \
    --file Dockerfile.$(NAME) .

