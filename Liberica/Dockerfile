ARG JAVA_TYPE=jre
ARG JAVA_VERSION=25
ARG LIBC_TYPE=glibc

FROM --platform=$TARGETOS/$TARGETARCH docker.io/bellsoft/liberica-runtime-container:${JAVA_TYPE}-${JAVA_VERSION}-${LIBC_TYPE}

LABEL authors="en0tuk"

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
    openssl \
    tar \
    sqlite \
    tzdata \
    iproute2 \
    shadow \
    libstdc++ \
    fontconfig \
    ttf-dejavu \
    font-terminus \
    && fc-cache -fv

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
