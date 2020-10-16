# syntax = docker/dockerfile:experimental

FROM golang:1.15 AS src

ARG VERSION
RUN git clone --depth=1 -b ${VERSION} https://github.com/istio/istio /go/src/
WORKDIR /go/src/

RUN --mount=type=cache,id=gomod,target=/go/pkg/mod go mod download

FROM busybox

COPY --from=src /go/src /go/src
