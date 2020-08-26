ARG VERSION

FROM golang:1.15 as builder

ARG VERSION

RUN git clone --depth=1 -b v${VERSION} https://github.com/jaegertracing/jaeger.git /go/src/github.com/jaegertracing/jaeger;

WORKDIR /go/src/github.com/jaegertracing/jaeger

RUN go get -u github.com/mjibson/esc
RUN git submodule update --init

COPY ./jaeger-ui/packages/jaeger-ui/build ./jaeger-ui/packages/jaeger-ui/build

RUN esc -pkg assets -o cmd/query/app/ui/actual/gen_assets.go -prefix jaeger-ui/packages/jaeger-ui/build jaeger-ui/packages/jaeger-ui/build
RUN esc -pkg assets -o cmd/query/app/ui/placeholder/gen_assets.go -prefix cmd/query/app/ui/placeholder/public cmd/query/app/ui/placeholder/public

RUN make build-all-in-one GOOS=$(go env GOOS) GOARCH=$(go env GOARCH)

FROM alpine:latest as certs
RUN apk add --update --no-cache ca-certificates

FROM scratch
ARG TARGETARCH

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Agent zipkin.thrift compact
EXPOSE 5775/udp
# Agent jaeger.thrift compact
EXPOSE 6831/udp
# Agent jaeger.thrift binary
EXPOSE 6832/udp
# Agent config HTTP
EXPOSE 5778
# Collector HTTP
EXPOSE 14268
# Collector gRPC
EXPOSE 14250
# Web HTTP
EXPOSE 16686

COPY --from=builder /go/src/github.com/jaegertracing/jaeger/cmd/all-in-one/all-in-one-linux-$TARGETARCH /go/bin/all-in-one-linux
COPY --from=builder /go/src/github.com/jaegertracing/jaeger/cmd/all-in-one/sampling_strategies.json /etc/jaeger/

VOLUME ["/tmp"]
ENTRYPOINT ["/go/bin/all-in-one-linux"]
CMD ["--sampling.strategies-file=/etc/jaeger/sampling_strategies.json"]