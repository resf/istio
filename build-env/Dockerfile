FROM morlay/google-gn:9a0496a7 as gn

FROM querycapistio/hsdis:latest as hsdis

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y \
    build-essential \
    apt-utils \
    unzip \
    git \
    make \
    cmake \
    automake \
    autoconf \
    libtool \
    virtualenv \
    python \
    vim \
    g++ \
    wget \
    ninja-build \
    curl \
    lsb-core \
    openjdk-11-jdk \
    software-properties-common \
    ; \
    rm -rf /var/lib/apt/lists/*;

## gn
COPY --from=gn /gn/gn /usr/local/bin/gn
RUN chmod +x /usr/local/bin/gn && gn --version

# hsdis-<arch>.so
COPY --from=hsdis /tmp/hsdis /tmp/hsdis
RUN set -eux; \
    \
    case $(uname -m) in \
        x86_64) \
            export ARCH=amd64; \
            export TARGETARCH=amd64; \
        ;; \
        aarch64) \
            export ARCH=aarch64; \
            export TARGETARCH=arm64; \
        ;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    \
    mkdir -p /usr/lib/jvm/java-11-openjdk-${TARGETARCH}/lib; \
    cp /tmp/hsdis/hsdis-${ARCH}.so /usr/lib/jvm/java-11-openjdk-${TARGETARCH}/lib/server/; \
    cp /tmp/hsdis/hsdis-${ARCH}.so /usr/lib/jvm/java-11-openjdk-${TARGETARCH}/lib/; \
    rm -rf /tmp/hsdis; 

## go
ENV GOVERSION=1.14.4
ENV GOPATH=/root/go  

RUN set -eux; \
    \
    case $(uname -m) in \
        x86_64) \
            export TARGETARCH=amd64; \
        ;; \
        aarch64) \
            export TARGETARCH=arm64; \
        ;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    curl -LO https://dl.google.com/go/go${GOVERSION}.linux-${TARGETARCH}.tar.gz; \
    tar -C /usr/local -xzf go${GOVERSION}.linux-${TARGETARCH}.tar.gz; \
    rm go${GOVERSION}.linux-${TARGETARCH}.tar.gz;

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"  

## bazel
RUN set -eux; \
    \
    case $(uname -m) in \
        x86_64) BAZELISK_URL=https://github.com/bazelbuild/bazelisk/releases/download/v1.5.0/bazelisk-linux-amd64;; \
        aarch64) BAZELISK_URL=https://github.com/Tick-Tocker/bazelisk-arm64/releases/download/arm64/bazelisk-linux-arm64;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    wget -O /usr/local/bin/bazel ${BAZELISK_URL}; \
    chmod +x /usr/local/bin/bazel; \
    \
    go get github.com/bazelbuild/buildtools/buildifier; \
    export BUILDIFIER_BIN=${GOPATH}/bin/buildifier; \
    \
    go get github.com/bazelbuild/buildtools/buildozer; \
    export BUILDOZER_BIN=${GOPATH}/bin/buildozer; \
    \
    rm -rf ${GOPATH}/src 


ENV LLVM_VERSION=9.0.0
ENV LLVM_PATH=/usr/lib/llvm-9

RUN set -eux; \
    \
    case $(uname -m) in \
        x86_64) export LLVM_RELEASE=clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04;; \
        aarch64) export LLVM_RELEASE=clang+llvm-${LLVM_VERSION}-aarch64-linux-gnu;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    \
    curl -LO  "https://releases.llvm.org/${LLVM_VERSION}/${LLVM_RELEASE}.tar.xz"; \
    tar Jxf "${LLVM_RELEASE}.tar.xz"; \
    mv "./${LLVM_RELEASE}" ${LLVM_PATH}; \
    chown -R root:root ${LLVM_PATH}; \
    rm "./${LLVM_RELEASE}.tar.xz"; \
    \
    echo "${LLVM_PATH}/lib" > /etc/ld.so.conf.d/llvm.conf; \
    ldconfig; 

ENV PATH="${LLVM_PATH}/bin:${PATH}"
