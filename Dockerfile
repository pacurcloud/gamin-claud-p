FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Escritorio ligero, audio, reproductor MP4 (mpv), atajos y dependencias gráficas
RUN apt-get update && apt-get install -y \
    curl wget git ca-certificates jq zenity mpv xbindkeys \
    xvfb x11vnc openbox xterm pulseaudio dbus-x11 \
    mesa-utils libgl1 libva-drm2 libva2 python3-websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Instalar Steam nativo
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    steam-installer \
    && rm -rf /var/lib/apt/lists/*

# Instalar Heroic Games Launcher obteniendo la URL exacta de la última release (evita error 404)
RUN HEROIC_URL=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest \
    | jq -r '.assets[] | select(.name | endswith("linux-amd64.deb")) | .browser_download_url' | head -n 1) \
    && wget -qO /tmp/heroic.deb "$HEROIC_URL" \
    && apt-get update && apt-get install -y /tmp/heroic.deb \
    && rm -f /tmp/heroic.deb /var/lib/apt/lists/*

# Instalar Sunshine (para streaming con mando cuando lo corras en host con GPU)
RUN SUNSHINE_URL=$(curl -s https://api.github.com/repos/LizardByte/Sunshine/releases/latest \
    | jq -r '.assets[] | select(.name | test("ubuntu-24.04-amd64\\.deb$")) | .browser_download_url' | head -n 1) \
    && wget -qO /tmp/sunshine.deb "$SUNSHINE_URL" \
    && apt-get update && apt-get install -y /tmp/sunshine.deb \
    && rm -f /tmp/sunshine.deb /var/lib/apt/lists/*

RUN mkdir -p /opt/gamin-claud-p /intros
COPY scripts/ /opt/gamin-claud-p/
RUN chmod +x /opt/gamin-claud-p/*.sh

CMD ["/opt/gamin-claud-p/launcher.sh"]
