# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH amazoncorretto:23

LABEL authors="vovamod <veganetworkmain@gmail.com>,en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER
ENV GITHUB_USER ${GITHUB_USER}

ENV DEBIAN_FRONTEND=noninteractive

RUN yum update -y \
    && yum install -y curl ca-certificates openssl git tar sqlite fontconfig tzdata locales iproute \
    && yum install -y glibc-locale-source glibc-langpack-en


ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN useradd -d /home/container -m container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
    