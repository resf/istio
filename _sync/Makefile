MIRRORHUB=hub-dev.demo.querycap.com
IMAGE=library/alpine:latest

sync-image:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	--build-arg IMAGE=${IMAGE} \
	--tag ${MIRRORHUB}/${IMAGE} \
	--file Dockerfile \
	.