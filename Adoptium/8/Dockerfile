# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG ADOPTIUM_VERSION=8u382b05
ARG ADOPTIUM_VERSION_CAT=jdk8u392-b08

MAINTAINER vovamod, <veganetworkmain@gmail.com>

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
  && apt-get install -y curl ca-certificates openssl git tar sqlite3 fontconfig tzdata locales iproute2 \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.UTF-8 \
  && case ${TARGETPLATFORM} in \
         "linux/amd64")  ARCH=x64  ;; \
         "linux/arm64")  ARCH=aarch64  ;; \
    esac \
  && curl --retry 3 -Lfso /tmp/adoptium.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/${ADOPTIUM_VERSION_CAT}/OpenJDK8U-jdk_${ARCH}_linux_hotspot_${ADOPTIUM_VERSION}.tar.gz \
  && mkdir -p /opt/java/adoptium \
  && cd /opt/java/adoptium \
  && tar -xf /tmp/adoptium.tar.gz --strip-components=1 \
  && export PATH="/opt/java/adoptium/bin:$PATH" \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/adoptium.tar.gz

ENV JAVA_HOME=/opt/java/adoptium \
    PATH="/opt/java/adoptium/bin:$PATH"

RUN useradd -d /home/container -m container

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh

CMD         ["/bin/bash", "/entrypoint.sh"]