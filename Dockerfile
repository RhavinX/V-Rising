FROM steamcmd/steamcmd:debian-12

LABEL org.opencontainers.image.authors="RhavinX" \
      org.opencontainers.image.source=https://github.com/RhavinX/V-Rising \
      org.opencontainers.image.description="V Rising Dedicated Server"

VOLUME ["/home/VRisingServer", "/data"]

ARG DEBIAN_FRONTEND=noninteractive
COPY start.sh /start.sh
RUN chmod +x /start.sh && rm /etc/apt/sources.list.d/debian.sources && useradd -ms /bin/bash steam && \
    mkdir -pm755 /etc/apt/keyrings && \
    apt-get update -y && apt-get upgrade -y && apt-get install -y --no-install-recommends wget && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
    apt-get update -y && apt-get install -y --no-install-recommends tzdata xdg-user-dirs procps \
    winehq-stable xvfb winbind && \
    apt-get purge -y wget && apt-get clean -y && apt-get autopurge -y && \    
    rm -rf /var/lib/apt/lists/*

EXPOSE 27015/udp
EXPOSE 27016/udp

ENTRYPOINT [ "/start.sh" ]
