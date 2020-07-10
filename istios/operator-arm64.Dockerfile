ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/operator:${VERSION} as operator
FROM ${BASE_DISTRIBUTION}

COPY ./bin/operator /usr/local/bin/operator
COPY --from=operator /var/lib/istio/manifests/ /var/lib/istio/manifests/

ENTRYPOINT ["/usr/local/bin/operator"]