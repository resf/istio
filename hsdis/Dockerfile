FROM debian:buster as builder

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -qqy --no-install-recommends \
        ca-certificates git \
        build-essential apt-utils libtool  \
        wget curl unzip \
        automake cmake make autoconf virtualenv \
        python ninja-build g++ \
        openjdk-11-jdk software-properties-common \
        ; \
    rm -rf /var/lib/apt/lists/*

# build hsdis-<arch>.so
# see https://metebalci.com/blog/how-to-build-the-hsdis-disassembler-plugin-on-ubuntu-18/
RUN set -eux; \
    \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list; \
    apt-get update; \
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
    mkdir -p /tmp/jdk && cd /tmp/jdk;  \
    apt-get source openjdk-11-jdk-headless; \
    cd $(ls -b | head -1)/src/utils/hsdis; \
    \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz; \
    tar -xzf binutils-2.32.tar.gz; \
    export BINUTILS=binutils-2.32; \
    sed -i -e 's/app_data->dfn = disassembler(native_bfd)/app_data->dfn = disassembler(bfd_get_arch(native_bfd),bfd_big_endian(native_bfd),bfd_get_mach(native_bfd),native_bfd)/g' hsdis.c;\
    make all64; \
    \
    mkdir -p /tmp/hsdis; \
    cp build/linux-${ARCH}/hsdis-${ARCH}.so /tmp/hsdis; \
    rm -rf /tmp/jdk; \
    rm -rf /var/lib/apt/lists/*

FROM busybox    

COPY --from=builder /tmp/hsdis /tmp/hsdis