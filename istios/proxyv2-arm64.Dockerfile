ARG VERSION
ARG BASE_DISTRIBUTION=default

FROM istio/proxyv2:${VERSION} as proxyv2

FROM ${BASE_DISTRIBUTION}

ARG VERSION=1.6.3

COPY --from=proxyv2 /var/lib/istio/envoy/envoy_bootstrap_tmpl.json /var/lib/istio/envoy/envoy_bootstrap_tmpl.json
COPY --from=proxyv2 /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json /var/lib/istio/envoy/gcp_envoy_bootstrap_tmpl.json

RUN chown -R istio-proxy /var/lib/istio

ADD https://github.com/querycap/istio-envoy-arm64/releases/download/${VERSION}/envoy /usr/local/bin/envoy

RUN chmod +x /usr/local/bin/envoy && \
    export ISTIO_META_VERSION=${VERSION} && \
    export ISTIO_META_ISTIO_PROXY_SHA="istio-proxy:$(/usr/local/bin/envoy --version | grep version | sed -e 's/.*version\: //g')"

COPY ./bin/pilot-agent /usr/local/bin/pilot-agent

COPY --from=proxyv2 /var/lib/istio/envoy/envoy_policy.yaml.tmpl /var/lib/istio/envoy/envoy_policy.yaml.tmpl
COPY --from=proxyv2 /etc/istio/extensions/stats-filter.wasm /etc/istio/extensions/stats-filter.wasm
COPY --from=proxyv2 /etc/istio/extensions/metadata-exchange-filter.wasm /etc/istio/extensions/metadata-exchange-filter.wasm

# The pilot-agent will bootstrap Envoy.
ENTRYPOINT ["/usr/local/bin/pilot-agent"]
