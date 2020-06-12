# istio oci image 

only for amd64 && arm64

## Usage

```
querycapistio/proxyv2:1.6.1
querycapistio/pilot:1.6.1
querycapistio/operator:1.6.1
```

### AMD64 

just pick from `istio/*:1.6.1`

### ARM64

updates istio build configration https://github.com/morlay/istio/tree/buildx-1.6.1

 * for compiling go files to arm64 version
 * on buildx branch run `TARGET_ARCH=arm64 BUILD_WITH_CONTAINER=1 HUB=querycapistio DOCKERX_PUSH=1 make dockerx` to compile and sync to docker.io as tmp image
    * in `proxyv2`, copy a arm64 `envoy` from https://github.com/morlay/istio-envoy-arm64 (built by docker https://github.com/morlay/istio-proxy-build-env)
    * other files from the tmp image
    * need to recreate the base image, because the istio/base only amd64 version



