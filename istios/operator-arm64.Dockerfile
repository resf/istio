ARG BINARY=querycapistio/operator:latest-arm64
ARG BASE=default
FROM ${BINARY} as binary
FROM ${BASE}

COPY --from=binary /usr/local/bin/operator /usr/local/bin/operator
COPY --from=binary /var/lib/istio/manifests/ /var/lib/istio/manifests/

ENTRYPOINT ["/usr/local/bin/operator"]