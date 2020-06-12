FROM querycapistio/istio-enovy-build-env:1.6.1 as builder

ARG VERSION=1.6.1

WORKDIR /go/src

RUN gn --version && bazel --version && ninja --version && clang++ --version

# clone istio/proxy
RUN set -eux; \
    \
    git clone https://github.com/istio/proxy /go/src/proxy; \
    cd /go/src/proxy; \
    git checkout ${VERSION};

WORKDIR /go/src/proxy

RUN set -eux; \
    \
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"; \
    export BAZEL_BUILD_ARGS="--sandbox_debug --verbose_failures --define=ABSOLUTE_JAVABASE=${JAVA_HOME} --javabase=@bazel_tools//tools/jdk:absolute_javabase --host_javabase=@bazel_tools//tools/jdk:absolute_javabase --java_toolchain=@bazel_tools//tools/jdk:toolchain_vanilla --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_vanilla"; \
    make build_envoy; \
    mkdir -p /envoy; \
    cp -r bazel-bin/src/envoy /envoy

FROM busybox

COPY --from=builder /envoy /envoy