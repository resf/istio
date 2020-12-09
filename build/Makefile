DOCKERX_CONTEXT ?= .
DOCKERX_NAME ?= default
DOCKERX_OUTPUT ?=
DOCKERX_PUSH ?= false
DOCKERX_ARCH_SUFFIX ?= false
DOCKERX_PLATFORMS ?= linux/amd64 linux/arm64
DOCKERX_BUILD_ARGS ?=
DOCKERX_LABELS ?=
DOCKERX_TAGS ?= latest
DOCKERX_TAG_SUFFIX ?=

ifeq ($(DOCKERX_PUSH),true)
	DOCKERX_OUTPUT = --push
endif

dockerx:
	@set -x; \
	\
	docker buildx build $(DOCKERX_OUTPUT) \
		$(foreach h,$(HUB),$(foreach t,$(DOCKERX_TAGS),--tag=$(h)/$(DOCKERX_NAME):$(t)$(DOCKERX_TAG_SUFFIX))) \
		$(foreach p,$(DOCKERX_PLATFORMS),--platform=$(p)) \
		$(foreach a,$(DOCKERX_BUILD_ARGS),--build-arg=$(a)) \
		$(foreach l,$(DOCKERX_LABELS),--label=$(l)) \
		--file $(DOCKERX_CONTEXT)/Dockerfile.$(DOCKERX_NAME) $(DOCKERX_CONTEXT)

imagetools:
	@set -x; \
	\
	for h in $(HUB); do \
	  for t in $(DOCKERX_TAGS); do \
	    docker buildx imagetools create \
	  	  --tag=$${h}/$(DOCKERX_NAME):$${t} \
	  	  $(foreach p,$(DOCKERX_PLATFORMS),$${h}/$(DOCKERX_NAME):$${t}-$(word 2,$(subst /, ,$(p)))); \
	  done; \
	done
