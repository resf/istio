ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/operator:${VERSION} as operator-amd64

FROM golang:1.15 as operator-arm64-builder

ARG VERSION
ARG GOPROXY=https://goproxy.io,direct

RUN git clone --depth=1 -b ${VERSION} https://github.com/istio/istio /go/src/istio.io/istio
WORKDIR /go/src/istio.io/istio

# https://github.com/istio/istio/tree/master/operator#building
RUN GO111MODULE=on go get github.com/jteeuwen/go-bindata/go-bindata@6025e8de665b
RUN ./operator/scripts/create_assets_gen.sh

# build operator
RUN STATIC=0 \
    GOOS=$(go env GOOS) \
    GOARCH=$(go env GOARCH) \
    LDFLAGS='-extldflags -static -s -w' \
    common/scripts/gobuild.sh /go/bin/ ./operator/cmd/operator

# https://github.com/istio/istio/blob/master/operator/docker/Dockerfile.operator
FROM ${BASE_DISTRIBUTION} as operator-arm64

# copy arm64 bin
COPY --from=operator-arm64-builder /go/bin/operator /usr/local/bin/operator

# copy manifests from offical amd64 image
COPY --from=operator-amd64 /var/lib/istio/manifests/ /var/lib/istio/manifests/

USER 1337:1337

ENTRYPOINT ["/usr/local/bin/operator"]

# for oci image, amd64 from offical, arm64 from rebuild
FROM operator-${TARGETARCH}