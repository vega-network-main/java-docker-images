# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG ZULU_VERSION=zulu17.46.19
ARG ZULU_JDK_VER=jdk17.0.9

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
  && curl --retry 3 -Lfso /tmp/azul.tar.gz https://cdn.azul.com/zulu/bin/${ZULU_VERSION}-ca-${ZULU_JDK_VER}-linux_${ARCH}.tar.gz \
  && mkdir -p /opt/java/azul \
  && cd /opt/java/azul \
  && tar -xf /tmp/azul.tar.gz --strip-components=1 \
  && export PATH="/opt/java/azul/bin:$PATH" \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/azul.tar.gz

ENV JAVA_HOME=/opt/java/azul \
    PATH="/opt/java/azul/bin:$PATH"

RUN useradd -d /home/container -m container

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh

CMD         ["/bin/bash", "/entrypoint.sh"]