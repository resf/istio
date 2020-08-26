ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/proxyv2:${VERSION} as proxyv2-amd64

FROM ${BASE_DISTRIBUTION} as proxyv2-arm64

ARG VERSION=1.6.3
ARG ENVOY_VERSION=""

COPY --from=proxyv2-amd64 /var/lib/istio/envoy/ /var/lib/istio/envoy/
COPY --from=proxyv2-amd64 /etc/istio/extensions/ /etc/istio/extensions/

RUN chown -R istio-proxy /var/lib/istio

ADD https://github.com/querycap/istio-envoy-arm64/releases/download/${VERSION}/envoy /usr/local/bin/envoy

RUN chmod +x /usr/local/bin/envoy

# Environment variable indicating the exact proxy sha - for debugging or version-specific configs
ENV ISTIO_META_ISTIO_PROXY_SHA ${ENVOY_VERSION}
# Environment variable indicating the exact build, for debugging
ENV ISTIO_META_ISTIO_VERSION ${VERSION}

COPY ./bin/pilot-agent /usr/local/bin/pilot-agent

# The pilot-agent will bootstrap Envoy.
ENTRYPOINT ["/usr/local/bin/pilot-agent"]

FROM proxyv2-${TARGETARCH}
