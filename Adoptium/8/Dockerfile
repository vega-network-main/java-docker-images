# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:8-jdk-jammy

LABEL authors="vovamod <veganetworkmain@gmail.com>"

ARG GITHUB_USER

ENV GITHUB_USER=${GITHUB_USER}
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'
ENV LC_ALL='en_US.UTF-8'
ENV TZ='UTC'
# debian_fix
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
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
    fonts-dejavu \
    fonts-terminus \
    fonts-noto \
    fonts-font-awesome \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
