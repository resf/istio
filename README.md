# istio OCI Images 

| Name | Docker Image | Architecture | 
|------|--------------|--------------|
| querycapistio/proxyv2 | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/proxyv2)](https://hub.docker.com/r/querycapistio/proxyv2) | `arm64/amd64` | 
| querycapistio/pilot | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/pilot)](https://hub.docker.com/r/querycapistio/pilot) | `arm64/amd64` |
| querycapistio/operator | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/operator)](https://hub.docker.com/r/querycapistio/operator) | `arm64/amd64` |

### AMD64 

just pick from `istio/*:1.6.1`

### ARM64

updates istio build configration https://github.com/morlay/istio/tree/buildx-1.6.1

 * for compiling go files to arm64 version
 * on buildx branch run `TARGET_ARCH=arm64 BUILD_WITH_CONTAINER=1 HUB=querycapistio DOCKERX_PUSH=1 make dockerx` to compile and sync to docker.io as tmp image
    * in `proxyv2`, copy a arm64 `envoy` from https://github.com/morlay/istio-envoy-arm64 (built by docker https://github.com/morlay/istio-proxy-build-env)
    * other files from the tmp image
    * need to recreate the base image, because the istio/base only amd64 version



