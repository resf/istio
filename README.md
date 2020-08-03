# istio OCI Images 

```
VERSION=1.6.3
VERSION=1.6.4
VERSION=1.6.5
VERSION=1.6.6
VERSION=1.6.7
```

| Name | Docker Image | Architecture | 
|------|--------------|--------------|
| querycapistio/proxyv2:${VERSION} | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/proxyv2)](https://hub.docker.com/r/querycapistio/proxyv2) | `arm64/amd64` | 
| querycapistio/pilot:${VERSION} | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/pilot)](https://hub.docker.com/r/querycapistio/pilot) | `arm64/amd64` |
| querycapistio/operator:${VERSION} | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/operator)](https://hub.docker.com/r/querycapistio/operator) | `arm64/amd64` |

### AMD64 

just pick from `istio/*:${VERSION}`

### ARM64

 * for compiling go files to arm64 version
 
 * `cd istios`
    * run `make build-binaries` to compile go binaries.
    * copy other files from the `istio/*:${VERSION}`
        * in `proxyv2`, copy a arm64 `envoy` form <https://github.com/querycap/istio-envoy-arm64/releases>
 
 * need to recreate the base image, because the istio/base only amd64 version
