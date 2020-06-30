VERSION=$(shell cat .version)
HUB=querycapistio

build:
	HUB=${HUB} VERSION=${VERSION} docker buildx bake -f ./bake.hcl --push
	./scripts/join.sh ${HUB}/proxyv2 ${VERSION}
	./scripts/join.sh ${HUB}/pilot ${VERSION}
	./scripts/join.sh ${HUB}/operator ${VERSION}

build-binaries:
	git clone https://github.com/morlay/istio .tmp/istio
	cd .tmp/istio && git checkout buildx-${VERSION} && sed -i -e 's/run -it/run/g' common/scripts/run.sh && \
	HUB=${HUB} TARGET_ARCH=arm64 TAG=${VERSION}-binary-arm64 BUILD_WITH_CONTAINER=1 make dockerx.pushx;
