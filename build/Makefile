TAGS = latest    master
BUILD_ARGS = VERSION=0.0.0 GOPROXY=https://goproxy.com,direct
TARGET_PLATFORM = linux/arm64,linux/amd64
DOCKERFILE = Dockerfile
CONTEXT = .

TAG_FLAGS = $(foreach v,$(TAGS),$(shell echo "--tag $(v)"))
BUILD_ARG_FLAGS = $(foreach v,$(BUILD_ARGS),$(shell echo "--build-arg $(v)"))

buildx:
	docker buildx build \
		--push \
		--platform $(TARGET_PLATFORM) \
		$(BUILD_ARG_FLAGS) \
		$(TAG_FLAGS) \
		--file $(DOCKERFILE) $(CONTEXT)
