ARG BINARY=querycapistio/proxyv2:latest-arm64
ARG BASE=default

FROM ${BINARY} as binary

FROM querycapistio/istio-enovy:1.6.2-arm64 as envoy

FROM ${BASE}

COPY --from=binary /var/lib/istio/envoy/envoy_bootstrap_tmpl.json /var/lib/istio/envoy/envoy_bootstrap_tmpl.json
COPY --from=binary /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json

RUN chown -R istio-proxy /var/lib/istio

ARG PROXY_VERSION
ARG VERSION

COPY --from=envoy /envoy/envoy/envoy /usr/local/bin/envoy
RUN chmod a+x /usr/local/bin/envoy

ENV ISTIO_META_ISTIO_PROXY_SHA $PROXY_VERSION
ENV ISTIO_META_VERSION $VERSION

COPY --from=binary /usr/local/bin/pilot-agent /usr/local/bin/pilot-agent
COPY --from=binary /var/lib/istio/envoy/envoy_policy.yaml.tmpl /var/lib/istio/envoy/envoy_policy.yaml.tmpl
COPY --from=binary /etc/istio/extensions/stats-filter.wasm /etc/istio/extensions/stats-filter.wasm
COPY --from=binary /etc/istio/extensions/metadata-exchange-filter.wasm /etc/istio/extensions/metadata-exchange-filter.wasm

# The pilot-agent will bootstrap Envoy.
ENTRYPOINT ["/usr/local/bin/pilot-agent"]
