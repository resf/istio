VERSION=$(shell cat .version)
HUB=querycapistio

build:
	HUB=${HUB} VERSION=${VERSION} docker buildx bake -f ./bake.hcl --push
	./scripts/join.sh ${HUB}/proxyv2 ${VERSION}
	./scripts/join.sh ${HUB}/pilot ${VERSION}
	./scripts/join.sh ${HUB}/operator ${VERSION}

build-binaries:
	HUB=${HUB} VERSION=${VERSION} ./scripts/build-binaries.sh