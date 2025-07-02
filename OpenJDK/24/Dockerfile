# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:24-jdk-alpine

LABEL authors="vovamod <veganetworkmain@gmail.com>, en0tuk <kolobokovich123@gmail.com>"

ARG GITHUB_USER

# Fix Docker ENV values
ENV GITHUB_USER ${GITHUB_USER}
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'
ENV LC_ALL 'en_US.UTF-8'
ENV TZ UTC

# Install required tools with no cache (we want to save space)
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
    msttcorefonts-installer && \
    update-ms-fonts && \
    fc-cache -f

# Fix JAVA: java.lang.RuntimeException: java.awt.FontFormatException: bad pfa font
RUN find /usr/share/fonts -type f \
    \( -iname "*.pfa" -o -iname "*.pfb" -o -iname "*.pcf" -o -iname "*.otb" \) -delete && \
    fc-cache -f

RUN useradd -m -d /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]