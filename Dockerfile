FROM debian:bullseye-slim

VOLUME ["/home/VRisingServer", "/data"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install apt-utils -y && \
    apt-get install -y software-properties-common -y && \
    add-apt-repository non-free && \
    dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get upgrade -y && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt purge steam steamcmd && \
    apt-get install -y --no-install-recommends steamcmd && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd && \
    apt install -y wine && \
    apt install -y xvfb && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean all && \
    apt autoremove -y

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 27015/udp
EXPOSE 27016/udp

ENTRYPOINT [ "/start.sh" ]
