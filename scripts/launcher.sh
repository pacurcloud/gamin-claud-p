#!/usr/bin/env bash
set -e

export DISPLAY=:1

# 1. Iniciar D-Bus y PulseAudio con salida virtual para Sunshine/Moonlight
mkdir -p /var/run/dbus
dbus-daemon --system --fork || true

pulseaudio --start --exit-idle-time=-1 || true
sleep 1
pactl load-module module-null-sink sink_name=gamin_sink sink_properties=device.description="gamin-claud-p-audio" || true
pactl set-default-sink gamin_sink || true

# 2. Iniciar servidor gráfico virtual (Xorg) y gestor de ventanas (Openbox)
Xorg :1 -nolisten tcp vt7 &
sleep 2
openbox-session &
sleep 1

# 3. Registrar atajo de teclado Ctrl + Alt + M para cambiar de plataforma
cat << 'EOF' > /root/.xbindkeysrc
"/opt/gamin-claud-p/switch-platform.sh"
  Control+Alt + m
EOF
xbindkeys -f /root/.xbindkeysrc &

# 4. Configurar credenciales de Sunshine y arrancarlo en segundo plano
sunshine --creds "${SUNSHINE_USER:-admin}" "${SUNSHINE_PASS:-admin1234}" || true
sunshine &
sleep 1

# 5. Abrir el menú selector de plataformas al iniciar
/opt/gamin-claud-p/switch-platform.sh

# Mantener contenedor activo
tail -f /dev/null
