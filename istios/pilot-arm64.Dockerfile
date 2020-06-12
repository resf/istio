ARG BINARY=querycapistio/pilot:latest-arm64
ARG BASE=default

FROM ${BINARY} as binary
FROM ${BASE}

COPY --from=binary /usr/local/bin/pilot-discovery /usr/local/bin/pilot-discovery
COPY --from=binary /cacert.pem /cacert.pem

ENTRYPOINT ["/usr/local/bin/pilot-discovery"]