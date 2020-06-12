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
 * on buildx branch run `TARGET_ARCH=arm64 BUILD_WITH_CONTAINER=1 HUB=querycapistio make dockerx.pushx` to compile and sync to docker.io as tmp image
    * in `proxyv2`, copy a arm64 `envoy` from https://github.com/morlay/istio-envoy-arm64 (built by docker https://github.com/morlay/istio-proxy-build-env)
    * other files from the tmp image
    * need to recreate the base image, because the istio/base only amd64 version

#### Stages

1. ![istio-envoy](https://github.com/querycap/istio/workflows/istio-envoy/badge.svg)
    * ![hsdis](https://github.com/querycap/istio/workflows/hsdis/badge.svg)
    * ![build-env](https://github.com/querycap/istio/workflows/build-env/badge.svg)
2. ![istio-arm64-binaries](https://github.com/querycap/istio/workflows/istio-arm64-binaries/badge.svg)
3. ![istios](https://github.com/querycap/istio/workflows/istios/badge.svg)