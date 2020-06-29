VERSION=$(shell cat .version)
HUB=querycapistio

build:
	HUB=${HUB} VERSION=${VERSION} docker buildx bake -f ./bake.hcl --push