FROM docker.io/steamcmd/steamcmd:debian-12

LABEL org.opencontainers.image.authors="RhavinX" \
      org.opencontainers.image.source=https://github.com/RhavinX/V-Rising \
      org.opencontainers.image.description="V Rising Dedicated Server"

VOLUME ["/home/VRisingServer", "/data"]

ARG DEBIAN_FRONTEND=noninteractive
RUN rm /etc/apt/sources.list.d/debian.sources && apt-get update && \
    apt-get install -y --no-install-recommends apt-utils wget software-properties-common tzdata xdg-user-dirs procps && \
    apt-get upgrade -y
RUN useradd -ms /bin/bash steam && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
    apt-get update -y && apt-get install -y --no-install-recommends winehq-stable xvfb && \
    apt-get purge -y wget software-properties-common && apt-get clean -y && apt-get autopurge -y && \    
    rm -rf /var/lib/apt/lists/* && cd /home/steam

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 27015/udp
EXPOSE 27016/udp

ENTRYPOINT [ "/start.sh" ]
