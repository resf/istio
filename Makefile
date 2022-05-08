# all need run on aarch host
VERSION = $(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )
GH_REPO ?= resf/istio
HUB ?= ghcr.io/$(GH_REPO)

# version tag or branch
# examples: make xxx TAG=1.11.0
TAG = $(VERSION)
RELEASE_BRANCH = master

TEMP_ROOT = ${PWD}/.tmp

GIT_CLONE = git clone
GIT_CLONE_TOOLS = git clone

RELEASE_BRANCH = release-$(word 1,$(subst ., ,$(VERSION))).$(word 2,$(subst ., ,$(VERSION)))
GIT_CLONE = git clone -b $(TAG)
GIT_CLONE_TOOLS = git clone -b $(RELEASE_BRANCH)

ENVOY_DIR = $(TEMP_ROOT)/envoy/$(RELEASE_BRANCH)

BUILD_TOOLS_VERSION = $(RELEASE_BRANCH)-latest
BUILD_TOOLS_IMAGE = $(HUB)/build-tools:$(BUILD_TOOLS_VERSION)
BUILD_TOOLS_PROXY_IMAGE = $(HUB)/build-tools-proxy:$(BUILD_TOOLS_VERSION)

echo:
	@echo "TAG: $(TAG)"
	@echo "RELEASE_BRANCH: $(RELEASE_BRANCH)"

ensure.build-tools:
	 sed -i -e 's/release-[0-9.]*/$(RELEASE_BRANCH)/g' .gitmodules
	 git submodule update --init --remote --force

# Build build-tools && build-tools-proxy for arm64
dockerx.build-tools:
	cd tools/docker/build-tools \
		&& DRY_RUN=1 HUB=$(HUB) CONTAINER_BUILDER="buildx build --push --platform=linux/arm64" ./build-and-push.sh

cleanup.proxy:
	rm -rf $(TEMP_ROOT)/proxy

ISTIO_ENVOY_VERSION = $(shell cat $(TEMP_ROOT)/istio/istio.deps | grep lastStableSHA | sed 's/.*"lastStableSHA": "\([a-zA-Z0-9]*\)"/\1/g')

# Clone istio/proxy
# To checkout last stable sha from istio/istio
clone.proxy: cleanup.istio clone.istio
	git clone https://github.com/istio/proxy.git $(TEMP_ROOT)/proxy
	cd $(TEMP_ROOT)/proxy && git checkout $(ISTIO_ENVOY_VERSION)


ENVOY_ORG = istio
ENVOY_REPO = envoy

# have to pre download the matched envoy and use --override_repository to overwrite to avoid private repo usage.
prepare.envoy:
	rm -rf $(ENVOY_DIR) && mkdir -p $(ENVOY_DIR)
	wget -c "https://github.com/$(ENVOY_ORG)/$(ENVOY_REPO)/archive/$(shell cat $(TEMP_ROOT)/proxy/WORKSPACE | grep "ENVOY_SHA = " | sed -e "s/ENVOY_SHA = //g" | sed -e "s/\"//g").tar.gz" \
		-O - | tar -xz -C $(ENVOY_DIR) --strip-components=1


# https://github.com/envoyproxy/envoy/issues/19089#issuecomment-1008222286
patch.gn:
	cd $(ENVOY_DIR) && patch -u -b bazel/external/wee8.genrule_cmd -i $(PWD)/patch/envoy.$(RELEASE_BRANCH).patch
	cat $(ENVOY_DIR)/bazel/external/wee8.genrule_cmd | grep "max-page-size"

# Build envoy
# /tmp/bazel here should must be link here, cause, bazel-out is symlink to TEST_TMPDIR
build.envoy: cleanup.proxy clone.proxy prepare.envoy
	docker pull $(HUB)/build-tools-proxy:$(BUILD_TOOLS_VERSION)
	docker run \
		-v=/tmp/bazel/$(RELEASE_BRANCH):/tmp/bazel/$(RELEASE_BRANCH) \
		-e=TEST_TMPDIR=/tmp/bazel/$(RELEASE_BRANCH) \
		-v=$(ENVOY_DIR):/tmp/envoy \
		-v=$(TEMP_ROOT)/proxy:/go/src/istio/proxy \
		-w=/go/src/istio/proxy \
		$(BUILD_TOOLS_PROXY_IMAGE) make build_envoy BAZEL_BUILD_ARGS="--override_repository=envoy=/tmp/envoy"
	mkdir -p $(TEMP_ROOT)/envoy-linux-arm64 && cp $(TEMP_ROOT)/proxy/bazel-bin/src/envoy/envoy $(TEMP_ROOT)/envoy-linux-arm64/envoy

cleanup.istio:
	rm -rf $(TEMP_ROOT)/istio

clone.istio:
	$(GIT_CLONE) --depth=1 https://github.com/istio/istio.git $(TEMP_ROOT)/istio

ISTIO_MAKE = cd $(TEMP_ROOT)/istio && IMG=$(BUILD_TOOLS_IMAGE) HUB=$(HUB) VERSION=$(VERSION) BASE_VERSION=$(TAG) TAG=$(TAG) make

DOCKER_COPY = docker run --rm \
              		--platform=linux/amd64 \
              		-v=$(TEMP_ROOT)/envoy-linux-amd64:/tmp \
              		--entrypoint=/bin/cp \
              		docker.io/istio/proxyv2:$(VERSION)

copy.envoy.from-image:
	$(DOCKER_COPY) /usr/local/bin/envoy /tmp/envoy
	$(DOCKER_COPY) -r /etc/istio/extensions /tmp/extensions

ISTIO_LINUX_AMD64_RELEASE_DIR = $(TEMP_ROOT)/istio/out/linux_amd64/release
ISTIO_LINUX_ARM64_RELEASE_DIR = $(TEMP_ROOT)/istio/out/linux_arm64/release

## avoid to download from google storage
## envoy-centos-$(ISTIO_ENVOY_VERSION) just a hack
copy.envoy: copy.envoy.from-image copy.envoy-amd64 copy.envoy-arm64 copy.wasm

copy.wasm:
	for f in $(TEMP_ROOT)/envoy-linux-amd64/extensions/*.wasm; do \
  		filename=$$(basename $${f}); \
  		cp $${f} "$(ISTIO_LINUX_AMD64_RELEASE_DIR)/$${filename}"; \
		cp $${f} "$(ISTIO_LINUX_AMD64_RELEASE_DIR)/$$(echo $${filename} | sed "s/-/_/g" | sed "s/_filter/-$(ISTIO_ENVOY_VERSION)/")"; \
  		cp $${f} "$(ISTIO_LINUX_ARM64_RELEASE_DIR)/$${filename}"; \
		cp $${f} "$(ISTIO_LINUX_ARM64_RELEASE_DIR)/$$(echo $${filename} | sed "s/-/_/g" | sed "s/_filter/-$(ISTIO_ENVOY_VERSION)/")"; \
	done

copy.envoy-amd64:
	rm -rf $(ISTIO_LINUX_AMD64_RELEASE_DIR) && mkdir -p $(ISTIO_LINUX_AMD64_RELEASE_DIR)
	cp $(TEMP_ROOT)/envoy-linux-amd64/envoy $(ISTIO_LINUX_AMD64_RELEASE_DIR)/envoy
	cp $(TEMP_ROOT)/envoy-linux-amd64/envoy $(ISTIO_LINUX_AMD64_RELEASE_DIR)/envoy-$(ISTIO_ENVOY_VERSION)
	cp $(TEMP_ROOT)/envoy-linux-amd64/envoy $(ISTIO_LINUX_AMD64_RELEASE_DIR)/envoy-centos-$(ISTIO_ENVOY_VERSION)

copy.envoy-arm64:
	rm -rf $(ISTIO_LINUX_ARM64_RELEASE_DIR) && mkdir -p $(ISTIO_LINUX_ARM64_RELEASE_DIR)
	cp $(TEMP_ROOT)/envoy-linux-arm64/envoy $(ISTIO_LINUX_ARM64_RELEASE_DIR)/envoy
	cp $(TEMP_ROOT)/envoy-linux-arm64/envoy $(ISTIO_LINUX_ARM64_RELEASE_DIR)/envoy-$(ISTIO_ENVOY_VERSION)
	cp $(TEMP_ROOT)/envoy-linux-arm64/envoy $(ISTIO_LINUX_ARM64_RELEASE_DIR)/envoy-centos-$(ISTIO_ENVOY_VERSION)

# Build istio binaries and copy envoy binary for arm64
# in github actions it will download from artifacts
build.istio: cleanup.istio clone.istio copy.envoy
	cd $(TEMP_ROOT)/istio \
    	&& $(ISTIO_MAKE) build-linux TARGET_ARCH=amd64
	cd $(TEMP_ROOT)/istio \
		&& $(ISTIO_MAKE) build-linux TARGET_ARCH=arm64

ESCAPED_HUB := $(shell echo $(HUB) | sed "s/\//\\\\\//g")

# Replace istio base images and pull latest BUILD_TOOLS_IMAGE
# sed must be gnu sed
dockerx.istio.prepare:
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.pilot
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/pilot/docker/Dockerfile.proxyv2
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/operator/docker/Dockerfile.operator
	sed -i -e 's/gcr.io\/istio-release\/\(base\|distroless\)/$(ESCAPED_HUB)\/\1/g' $(TEMP_ROOT)/istio/cni/deployments/kubernetes/Dockerfile.install-cni
	docker pull $(BUILD_TOOLS_IMAGE)

DOCKER_ARCHITECTURES="linux/amd64,linux/arm64"
# Build istio base images as multi-arch
dockerx.istio-base:
	$(ISTIO_MAKE) push.docker.base DOCKER_ARCHITECTURES=$(DOCKER_ARCHITECTURES)
	$(ISTIO_MAKE) push.docker.distroless DOCKER_ARCHITECTURES=$(DOCKER_ARCHITECTURES)

COMPONENTS = proxyv2 pilot operator install-cni
dockerx.istio-images: dockerx.istio.prepare dockerx.istio-base
	$(foreach component,$(COMPONENTS),cd $(TEMP_ROOT)/istio && $(ISTIO_MAKE) push.docker.$(component) DOCKER_BUILD_VARIANTS="default distroless" DOCKER_ARCHITECTURES=$(DOCKER_ARCHITECTURES);)

# Build istio deb
deb:
	$(ISTIO_MAKE) deb TARGET_ARCH=arm64
	mkdir -p $(TEMP_ROOT)/deb
	cp $(ISTIO_LINUX_ARM64_RELEASE_DIR)/istio-sidecar.deb $(TEMP_ROOT)/istio-sidecar.deb
	cp $(ISTIO_LINUX_ARM64_RELEASE_DIR)/istio.deb $(TEMP_ROOT)/istio.deb

check.istio:
	@echo "ISTIO_ENVOY_VERSION: $(ISTIO_ENVOY_VERSION)"
	docker pull --platform=linux/arm64 $(HUB)/proxyv2:$(VERSION)-distroless
	docker run --rm --platform=linux/arm64 --entrypoint=/usr/local/bin/envoy $(HUB)/proxyv2:$(VERSION)-distroless --version

# to initials packages on ghcr.io
# could be used to check access too
ALL_IMAGES=build-tools build-tools-proxy $(COMPONENTS)
ensure.ghcr.packages:
	$(foreach component,$(ALL_IMAGES),\
		docker buildx build --push \
          --label=org.opencontainers.image.source=https://github.com/$(GH_REPO) \
          --tag=$(HUB)/$(component):initial \
          -f Dockerfile.initial .github;)

setup.rocky-linux:
	dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
	dnf install docker-ce --allowerasing -y
	systemctl start docker
	systemctl enable docker
	dnf install git make wget -y