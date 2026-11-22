FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Dependencias base, gráficos, audio y soporte de mandos
RUN apt-get update && apt-get install -y \
    curl wget git ca-certificates gnupg software-properties-common \
    xorg xserver-xorg-video-dummy openbox xbindkeys xdotool zenity \
    pulseaudio dbus-x11 mesa-utils vulkan-tools libgl1 \
    libva-drm2 libva2 vainfo ffmpeg joystick input-utils \
    && rm -rf /var/lib/apt/lists/*

# Instalar Steam y navegador para Xbox Cloud
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    steam-installer chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# Instalar Heroic Games Launcher (Epic Games + Proton/Wine)
RUN wget -qO /tmp/heroic.deb "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/heroic_amd64.deb" \
    && apt-get update && apt-get install -y /tmp/heroic.deb \
    && rm -f /tmp/heroic.deb /var/lib/apt/lists/*

# Instalar Sunshine (servidor compatible con Moonlight)
RUN wget -qO /tmp/sunshine.deb "https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-24.04-amd64.deb" \
    && apt-get update && apt-get install -y /tmp/sunshine.deb \
    && rm -f /tmp/sunshine.deb /var/lib/apt/lists/*

RUN mkdir -p /opt/gamin-claud-p /config /games
COPY scripts/ /opt/gamin-claud-p/
RUN chmod +x /opt/gamin-claud-p/*.sh

CMD ["/opt/gamin-claud-p/launcher.sh"]
