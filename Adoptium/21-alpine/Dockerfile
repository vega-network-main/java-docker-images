# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:21-jdk-alpine

LABEL authors="vovamod <veganetworkmain@gmail.com>,en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER
ENV GITHUB_USER ${GITHUB_USER}

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV DEBIAN_FRONTEND=noninteractive

RUN apk update --no-cache \
  && apk add curl ca-certificates openssl git tar sqlite fontconfig tzdata iproute2


RUN adduser -D -h /home/container container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/sh", "/entrypoint.sh"]
