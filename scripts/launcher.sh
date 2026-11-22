#!/usr/bin/env bash
set -e

export DISPLAY=:1

# Iniciar D-Bus y PulseAudio
mkdir -p /var/run/dbus
dbus-daemon --system --fork || true
pulseaudio --start --exit-idle-time=-1 || true

# Iniciar servidor gráfico virtual a 1080p 60Hz y gestor de ventanas
Xorg :1 -nolisten tcp vt7 &
sleep 2
openbox-session &
sleep 1

# Configurar combinación de teclas Ctrl + Alt + M para cambiar de plataforma
cat << 'EOF' > /root/.xbindkeysrc
"/opt/gamin-claud-p/switch-platform.sh"
  Control+Alt + m
EOF
xbindkeys -f /root/.xbindkeysrc &

# Configurar credenciales iniciales de Sunshine y arrancarlo en segundo plano
sunshine --creds "${SUNSHINE_USER:-admin}" "${SUNSHINE_PASS:-admin1234}" || true
sunshine &

# Lanzar selector de plataforma al iniciar
/opt/gamin-claud-p/switch-platform.sh

# Mantener contenedor activo
tail -f /dev/null
