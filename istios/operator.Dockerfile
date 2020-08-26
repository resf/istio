ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/operator:${VERSION} as operator-amd64

FROM ${BASE_DISTRIBUTION} as operator-arm64

COPY ./bin/operator /usr/local/bin/operator
COPY --from=operator-amd64 /var/lib/istio/manifests/ /var/lib/istio/manifests/

ENTRYPOINT ["/usr/local/bin/operator"]

FROM operator-${TARGETARCH}