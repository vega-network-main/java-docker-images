# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG OPENJDK_VER=openjdk-17.0.2

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
  && curl --retry 3 -Lfso /tmp/openjdk.tar.gz https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/${OPENJDK_VER}_linux-${ARCH}_bin.tar.gz \
  && mkdir -p /opt/java/openjdk \
  && cd /opt/java/openjdk \
  && tar -xf /tmp/openjdk.tar.gz --strip-components=1 \
  && export PATH="/opt/java/openjdk/bin:$PATH" \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/openjdk.tar.gz

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

RUN useradd -d /home/container -m container

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh

CMD         ["/bin/bash", "/entrypoint.sh"]