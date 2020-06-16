ARG BINARY=querycapistio/proxyv2:latest-arm64
ARG BASE=default
ARG ISTIO_ENVOY_SHA=9e2704aa828400b4c5e0b9c54db46c538d2b1ebf

FROM ${BINARY} as binary

FROM querycapistio/istio-enovy:${ISTIO_ENVOY_SHA}-arm64 as envoy

FROM ${BASE}

COPY --from=binary /var/lib/istio/envoy/envoy_bootstrap_tmpl.json /var/lib/istio/envoy/envoy_bootstrap_tmpl.json
COPY --from=binary /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json

RUN chown -R istio-proxy /var/lib/istio

ARG PROXY_VERSION
ARG VERSION

COPY --from=envoy /envoy/envoy/envoy /usr/local/bin/envoy
RUN chmod a+x /usr/local/bin/envoy

ENV ISTIO_META_ISTIO_PROXY_SHA istio-proxy:${ISTIO_ENVOY_SHA}
ENV ISTIO_META_VERSION $VERSION

COPY --from=binary /usr/local/bin/pilot-agent /usr/local/bin/pilot-agent
COPY --from=binary /var/lib/istio/envoy/envoy_policy.yaml.tmpl /var/lib/istio/envoy/envoy_policy.yaml.tmpl
COPY --from=binary /etc/istio/extensions/stats-filter.wasm /etc/istio/extensions/stats-filter.wasm
COPY --from=binary /etc/istio/extensions/metadata-exchange-filter.wasm /etc/istio/extensions/metadata-exchange-filter.wasm

# The pilot-agent will bootstrap Envoy.
ENTRYPOINT ["/usr/local/bin/pilot-agent"]
