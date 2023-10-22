# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM --platform=$TARGETOS/$TARGETARCH amazoncorretto:21.0.1

MAINTAINER vovamod, <veganetworkmain@gmail.com>

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV DEBIAN_FRONTEND=noninteractive

RUN yum update -y \
  && yum install -y curl ca-certificates openssl git tar sqlite3 fontconfig tzdata locales iproute2


RUN useradd -d /home/container -m container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
