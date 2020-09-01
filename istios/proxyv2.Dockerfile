# syntax = docker/dockerfile:experimental

ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/proxyv2:${VERSION} as proxyv2-amd64

FROM golang:1.15 as proxyv2-arm64-builder

ARG VERSION
ARG GOPROXY=https://goproxy.io,direct

RUN git clone --depth=1 -b ${VERSION} https://github.com/istio/istio /go/src/istio.io/istio
WORKDIR /go/src/istio.io/istio

# build pilot-agent
RUN --mount=type=cache,id=gomod,target=/go/pkg/mod \
    STATIC=0 \
    GOOS=$(go env GOOS) \
    GOARCH=$(go env GOARCH) \
    LDFLAGS='-extldflags -static -s -w' \
    common/scripts/gobuild.sh /go/bin/ ./pilot/cmd/pilot-agent

# https://github.com/istio/istio/blob/master/pilot/docker/Dockerfile.proxyv2
FROM ${BASE_DISTRIBUTION} as proxyv2-arm64

ARG VERSION=1.6.3
ARG ENVOY_VERSION=""

# add envoy
# built on arm64 hosts
# see more https://github.com/querycap/istio-envoy-arm64
ADD https://github.com/querycap/istio-envoy-arm64/releases/download/${VERSION}/envoy /usr/local/bin/envoy

# important for metrics
ENV ISTIO_META_ISTIO_PROXY_SHA ${ENVOY_VERSION}
ENV ISTIO_META_ISTIO_VERSION ${VERSION}

# copy arm64 bin
COPY --from=proxyv2-arm64-builder /go/bin/pilot-agent /usr/local/bin/pilot-agent

# copy static files from offical amd64 image
COPY --from=proxyv2-amd64 /var/lib/istio/envoy/ /var/lib/istio/envoy/
COPY --from=proxyv2-amd64 /etc/istio/extensions/ /etc/istio/extensions/

## permission fix
RUN chmod +x /usr/local/bin/envoy \
    && chown -R istio-proxy /var/lib/istio

ENTRYPOINT ["/usr/local/bin/pilot-agent"]

# for oci image, amd64 from offical, arm64 from rebuild
FROM proxyv2-${TARGETARCH}
