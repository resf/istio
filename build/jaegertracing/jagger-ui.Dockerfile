FROM node as builder

RUN git clone --depth=1 https://github.com/jaegertracing/jaeger-ui /app/jaeger-ui
WORKDIR /app/jaeger-ui
RUN  yarn install --frozen-lockfile && cd packages/jaeger-ui && yarn build

FROM busybox

COPY --from=builder /app/jaeger-ui/packages/jaeger-ui/build /jaeger-ui