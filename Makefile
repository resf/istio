HUB ?= docker.io/querycapistio
TEMP_ROOT = ${PWD}/.tmp

BUILD_TOOLS_VERSION = master-latest

clean.build-tools:
	rm -rf $(TEMP_ROOT)/tools

clone.build-tools:
	git clone --depth=1 https://github.com/istio/tools.git $(TEMP_ROOT)/tools

# Build build-tools-proxy for arm64
# need run aarch64 host
dockerx.build-tools: clean.build-tools clone.build-tools
	cd $(TEMP_ROOT)/tools/docker/build-tools \
		&& DRY_RUN=1 HUB=$(HUB) CONTAINER_BUILDER="buildx build --push --platform=linux/arm64" ./build-and-push.sh

# version tag or branch
# examples: make xxx TAG=1.11.0
TAG = master

GIT_CLONE = git clone

ifneq ($(TAG),master)
	GIT_CLONE = git clone -b $(TAG)
endif

cleanup.envoy:
	rm -rf $(TEMP_ROOT)/proxy

# Clone istio/proxy
# To checkout last stable sha from istio/istio
clone.envoy: cleanup.istio clone.istio
	git clone https://github.com/istio/proxy.git $(TEMP_ROOT)/proxy
	cd $(TEMP_ROOT)/proxy && git checkout $(shell cat $(TEMP_ROOT)/istio/istio.deps | grep lastStableSHA | sed 's/.*"lastStableSHA": "\([a-zA-Z0-9]*\)"/\1/g')

# Build envoy
# need run aarch64 host
# /tmp/bazel here should must be link here, cause, bazel-out is symlink to TEST_TMPDIR
build.envoy: cleanup.envoy clone.envoy
	docker pull $(HUB)/build-tools-proxy:$(BUILD_TOOLS_VERSION)
	docker run \
		-e=ENVOY_ORG=istio \
		-e=TEST_TMPDIR=/tmp/bazel \
		-v=/tmp/bazel:/tmp/bazel \
		-v=$(TEMP_ROOT)/proxy:/go/src/istio/proxy \
		-w=/go/src/istio/proxy \
		$(HUB)/build-tools-proxy:$(BUILD_TOOLS_VERSION) make build_envoy
	mkdir -p $(TEMP_ROOT)/envoy-linux-arm64 && cp $(TEMP_ROOT)/proxy/bazel-bin/src/envoy/envoy $(TEMP_ROOT)/envoy-linux-arm64/envoy

cleanup.istio:
	rm -rf $(TEMP_ROOT)/istio

clone.istio:
	$(GIT_CLONE) --depth=1 https://github.com/istio/istio.git $(TEMP_ROOT)/istio


ISTIO_ENVOY_LINUX_ARM64_RELEASE_DIR = $(TEMP_ROOT)/istio/out/linux_arm64/release

AGENT_BINARIES := ./pilot/cmd/pilot-agent
STANDARD_BINARIES := ./pilot/cmd/pilot-discovery ./operator/cmd/operator

# Build istio binaries and copy envoy binary for arm64
# in github actions it will download from artifacts
build.istio:
	cd $(TEMP_ROOT)/istio \
    		&& make build-linux TARGET_ARCH=amd64 STANDARD_BINARIES="$(STANDARD_BINARIES)" AGENT_BINARIES="$(AGENT_BINARIES)"
	cd $(TEMP_ROOT)/istio \
		&& make build-linux TARGET_ARCH=arm64 STANDARD_BINARIES="$(STANDARD_BINARIES)" AGENT_BINARIES="$(AGENT_BINARIES)" \
		&& cp $(TEMP_ROOT)/envoy-linux-arm64/envoy $(ISTIO_ENVOY_LINUX_ARM64_RELEASE_DIR)/envoy

ESCAPED_HUB := $(shell echo $(HUB) | sed "s/\//\\\\\//g")

# Replace istio base images
# sed must be gnu sed
dockerx.istio.prepare:
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.pilot
	cat $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.pilot
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.proxyv2
	cat $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.proxyv2
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/operator/docker/Dockerfile.operator
	cat $(TEMP_ROOT)/istio/operator/docker/Dockerfile.operator

COMPONENTS = proxyv2 pilot operator

# Build istio base images as multi-arch
# need run x86_64 host
dockerx.istio-base:
	cd $(TEMP_ROOT)/istio && make dockerx.base TARGET_ARCH=amd64 HUB=$(HUB) TAG=$(TAG) DOCKERX_PUSH=true DOCKER_ARCHITECTURES=linux/amd64,linux/arm64
	cd $(TEMP_ROOT)/istio && make dockerx.distroless TARGET_ARCH=amd64 HUB=$(HUB) TAG=$(TAG) DOCKERX_PUSH=true DOCKER_ARCHITECTURES=linux/amd64,linux/arm64

# Build istio images  as multi-arch
# need run x86_64 host
dockerx.istio: cleanup.istio clone.istio dockerx.istio.prepare dockerx.istio-base build.istio
	$(foreach component,$(COMPONENTS),cd $(TEMP_ROOT)/istio && make dockerx.$(component) TARGET_ARCH=amd64 HUB=$(HUB) BASE_VERSION=$(TAG) TAG=$(TAG) DOCKERX_PUSH=true DOCKER_BUILD_VARIANTS="default distroless" DOCKER_ARCHITECTURES=linux/amd64,linux/arm64;)
