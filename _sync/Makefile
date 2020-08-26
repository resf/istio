MIRRORHUB=registry.cn-hangzhou.aliyuncs.com
IMAGE="nginx"

sync-image:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	--build-arg IMAGE=${IMAGE} \
	--tag ${MIRRORHUB}/${IMAGE} \
	--file Dockerfile \
	.