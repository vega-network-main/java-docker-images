# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH azul/zulu-openjdk-alpine:17

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
    font-noto \
    font-awesome


RUN useradd -m -d /home/container container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]