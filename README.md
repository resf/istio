# Istio OCI Images 


## `querycapistio/{proxyv2,pilot,operator}:{1.6.8,1.7.0}`

| Name | Docker Image | Architecture | 
|------|--------------|--------------|
| `querycapistio/proxyv2:${VERSION}` | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/proxyv2)](https://hub.docker.com/r/querycapistio/proxyv2) | `arm64/amd64` | 
| `querycapistio/pilot:${VERSION}` | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/pilot)](https://hub.docker.com/r/querycapistio/pilot) | `arm64/amd64` |
| `querycapistio/operator:${VERSION}` | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/operator)](https://hub.docker.com/r/querycapistio/operator) | `arm64/amd64` |


## `querycap/kiali:{v1.22.1}`

| Name | Docker Image | Architecture | 
|------|--------------|--------------|
| `querycap/kiali:${VERSION}` | [![Docker Pulls](https://img.shields.io/docker/pulls/querycap/kiali)](https://hub.docker.com/r/querycap/kiali) | `arm64/amd64` | 


## `querycapjaegertracing/all-in-one:{1.18.1}`

| Name | Docker Image | Architecture | 
|------|--------------|--------------|
| `querycapjaegertracing/all-in-one:${VERSION}` | [![Docker Pulls](https://img.shields.io/docker/pulls/querycapjaegertracing/all-in-one)](https://hub.docker.com/r/querycapjaegertracing/all-in-one) | `arm64/amd64` | 


### How to build istio images?

#### AMD64 

just pick from `istio/*:${VERSION}`

#### ARM64

 * for compiling go files to arm64 version
 
 * `cd istios`
    * run `make build-binaries` to compile go binaries.
    * copy other files from the `istio/*:${VERSION}`
        * in `proxyv2`, copy a arm64 `envoy` form <https://github.com/querycap/istio-envoy-arm64/releases>
 
 * need to recreate the base image, because the istio/base only amd64 version
