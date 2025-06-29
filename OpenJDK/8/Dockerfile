# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
# GH Worker does not support non-ARM images? docker.io/library/eclipse-temurin:8-jdk-alpine
FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:8-jdk

LABEL authors="vovamod <veganetworkmain@gmail.com>, en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER

# Fix Docker ENV values
ENV GITHUB_USER ${GITHUB_USER}
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'
ENV LC_ALL 'en_US.UTF-8'
ENV TZ UTC

# Install required tools with no cache (we want to save space)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        ca-certificates \
        git \
        openssl \
        tar \
        sqlite3 \
        fontconfig \
        tzdata \
        iproute2 \
        shadow && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]