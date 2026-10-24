ARG JAVA_TYPE=jre
ARG JAVA_VERSION=25
ARG LIBC_TYPE=glibc

# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM docker.io/bellsoft/liberica-runtime-container:${JAVA_TYPE}-${JAVA_VERSION}-${LIBC_TYPE}

LABEL authors="en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER

ENV GITHUB_USER=${GITHUB_USER}
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV TZ='UTC'

RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    git \
    openssl \
    tar \
    sqlite \
    tzdata \
    iproute2 \
    shadow \
    libstdc++ \
    fontconfig \
    font-dejavu \
    font-terminus \
    && useradd -m -d /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
