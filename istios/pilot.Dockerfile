ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/pilot:${VERSION} as pilot-amd64

FROM ${BASE_DISTRIBUTION} as pilot-arm64

COPY ./bin/pilot-discovery /usr/local/bin/pilot-discovery
COPY --from=pilot-amd64 /cacert.pem /cacert.pem

USER 1337:1337

ENTRYPOINT ["/usr/local/bin/pilot-discovery"]

FROM pilot-${TARGETARCH}