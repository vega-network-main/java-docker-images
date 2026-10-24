# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$BUILDPLATFORM debian:13-slim AS graalvm

ARG TARGETARCH
ARG GRAAL_URL_AMD64=https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-23.0.2/graalvm-community-jdk-23.0.2_linux-x64_bin.tar.gz
ARG GRAAL_SHA256_AMD64=0cf63e88153b759136947c14f0042c515ae1ff9abf346f143dc47af065b1d6dd
ARG GRAAL_URL_ARM64=https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-23.0.2/graalvm-community-jdk-23.0.2_linux-aarch64_bin.tar.gz
ARG GRAAL_SHA256_ARM64=70d0ee8cb1922fbfe5a5db6a93360f63bbf0bdf72a6ca1f9b00906e600628c19

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && case "${TARGETARCH}" in \
        amd64) URL="${GRAAL_URL_AMD64}"; SHA256="${GRAAL_SHA256_AMD64}" ;; \
        arm64) URL="${GRAAL_URL_ARM64}"; SHA256="${GRAAL_SHA256_ARM64}" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL --retry 3 -o /tmp/graalvm.tar.gz "${URL}" \
    && echo "${SHA256}  /tmp/graalvm.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/java/graalvm \
    && tar -xzf /tmp/graalvm.tar.gz -C /opt/java/graalvm --strip-components=1

FROM debian:13-slim

LABEL authors="vovamod <veganetworkmain@gmail.com>, en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER

ENV GITHUB_USER=${GITHUB_USER}
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV TZ='UTC'
ENV JAVA_HOME=/opt/java/graalvm
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    git \
    openssl \
    tar \
    sqlite3 \
    tzdata \
    locales \
    iproute2 \
    fontconfig \
    fonts-dejavu-core \
    fonts-terminus \
    fonts-noto \
    fonts-font-awesome \
    && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container container

COPY --from=graalvm /opt/java/graalvm /opt/java/graalvm

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
