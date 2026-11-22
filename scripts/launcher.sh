#!/usr/bin/env bash
set -e

export DISPLAY=:1

# 1. Iniciar servidor gráfico virtual HD y audio
Xvfb :1 -screen 0 1280x720x24 &
sleep 1
openbox-session &
pulseaudio --start --exit-idle-time=-1 || true

# 2. Exponer pantalla en el puerto 8080 vía noVNC
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -forever -shared &
websockify --web=/usr/share/novnc/ 8080 localhost:5900 &

# 3. Registrar atajo Ctrl + Alt + M para cambiar de plataforma
cat << 'EOF' > /root/.xbindkeysrc
"/opt/gamin-claud-p/switch-platform.sh"
  Control+Alt + m
EOF
xbindkeys -f /root/.xbindkeysrc &

# 4. Abrir terminal visible en pantalla con animación "Cargando servicios..."
xterm -fa "Monospace" -fs 12 -bg black -fg cyan -T "gamin-claud-p | Cargando servicios..." -e bash -c '
  clear
  echo "===================================================="
  echo "               GAMIN - CLAUD - P                    "
  echo "===================================================="
  echo ""
  spin="|/-\\"
  pasos=("Iniciando entorno grafico y audio" "Verificando intros xbox.mp4 / steam.mp4 / epic.mp4" "Configurando sesion temporal" "Preparando clientes Steam, Epic y Xbox")
  pct=0
  for paso in "${pasos[@]}"; do
    pct=$((pct + 25))
    for i in $(seq 1 12); do
      c=${spin:$((i % 4)):1}
      printf "\r  [%c] Cargando servicios... (%d%%) - %s   " "$c" "$pct" "$paso"
      sleep 0.1
    done
  done
  printf "\r  [OK] Cargando servicios... (100%%) - ¡Listo!                    \n\n"
  sleep 1
  /opt/gamin-claud-p/switch-platform.sh
  exec bash
' &

tail -f /dev/null
