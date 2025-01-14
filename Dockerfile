FROM steamcmd/steamcmd:debian-12

LABEL org.opencontainers.image.authors="RhavinX" \
      org.opencontainers.image.source=https://github.com/RhavinX/V-Rising \
      org.opencontainers.image.description="V Rising Dedicated Server"

ARG DEBIAN_FRONTEND=noninteractive

COPY start.sh /start.sh
ADD --chmod=755 https://dl.winehq.org/wine-builds/winehq.key /etc/apt/keyrings/winehq-archive.key
ADD https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources /etc/apt/sources.list.d/winehq-bookworm.sources
RUN mkdir -p /home/VRisingServer /data && chmod +x /start.sh && rm /etc/apt/sources.list.d/debian.sources && useradd -ms /bin/bash steam && \
    apt-get update -y && apt-get install -y --no-install-recommends tzdata xdg-user-dirs procps winehq-stable xvfb winbind && \
    apt-get clean -y && apt-get autopurge -y && rm -rf /var/lib/apt/lists/*

VOLUME ["/home/VRisingServer", "/data"]
EXPOSE 27015/udp
EXPOSE 27016/udp

ENTRYPOINT [ "/start.sh" ]
