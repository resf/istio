ARG BINARY=querycapistio/proxyv2:latest-arm64
ARG BASE=default

FROM ${BINARY} as binary
FROM ${BASE}

ARG VERSION=1.6.3

COPY --from=binary /var/lib/istio/envoy/envoy_bootstrap_tmpl.json /var/lib/istio/envoy/envoy_bootstrap_tmpl.json
COPY --from=binary /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json

RUN chown -R istio-proxy /var/lib/istio

ADD https://github.com/querycap/istio-envoy-arm64/releases/download/${VERSION}/envoy /usr/local/bin/envoy

RUN chmod +x /usr/local/bin/envoy && \
    export ISTIO_META_VERSION=${VERSION} && \
    export ISTIO_META_ISTIO_PROXY_SHA="istio-proxy:$(/usr/local/bin/envoy --version | grep version | sed -e 's/.*version\: //g')"

COPY --from=binary /usr/local/bin/pilot-agent /usr/local/bin/pilot-agent
COPY --from=binary /var/lib/istio/envoy/envoy_policy.yaml.tmpl /var/lib/istio/envoy/envoy_policy.yaml.tmpl
COPY --from=binary /etc/istio/extensions/stats-filter.wasm /etc/istio/extensions/stats-filter.wasm
COPY --from=binary /etc/istio/extensions/metadata-exchange-filter.wasm /etc/istio/extensions/metadata-exchange-filter.wasm

# The pilot-agent will bootstrap Envoy.
ENTRYPOINT ["/usr/local/bin/pilot-agent"]
