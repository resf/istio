# syntax = docker/dockerfile:experimental

FROM golang:1.15 AS src

ARG VERSION
RUN git clone --depth=1 -b v${VERSION} https://github.com/jaegertracing/jaeger.git /go/src/
WORKDIR /go/src/

RUN git submodule update --init

FROM node AS ui

COPY --from=src /go/src/jaeger-ui /go/src/jaeger-ui
WORKDIR /go/src/jaeger-ui
RUN yarn install --frozen-lockfile && cd packages/jaeger-ui && yarn build

FROM golang:1.15 AS prebuild

COPY --from=src /go/src /go/src
COPY --from=ui /go/src/jaeger-ui/packages/jaeger-ui/build /go/src/jaeger-ui/packages/jaeger-ui/build

WORKDIR /go/src/

RUN --mount=type=cache,id=gomod,target=/go/pkg/mod go mod download
RUN --mount=type=cache,id=gomod,target=/go/pkg/mod go get -u github.com/mjibson/esc

RUN esc -pkg assets -o cmd/query/app/ui/actual/gen_assets.go -prefix jaeger-ui/packages/jaeger-ui/build jaeger-ui/packages/jaeger-ui/build
RUN esc -pkg assets -o cmd/query/app/ui/placeholder/gen_assets.go -prefix cmd/query/app/ui/placeholder/public cmd/query/app/ui/placeholder/public

FROM busybox

COPY --from=prebuild /go/src /go/src
