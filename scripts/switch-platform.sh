#!/usr/bin/env bash
export DISPLAY=:1

CHOICE=$(zenity --list \
  --title="gamin-claud-p | Selector de Plataforma" \
  --text="Elige qué plataforma iniciar (Atajo para cambiar: Ctrl + Alt + M o Guía + Start en Moonlight):" \
  --width=520 --height=320 \
  --column="ID" --column="Plataforma" --column="Descripción" \
  "steam" "Steam (Big Picture)" "Biblioteca Steam y Proton para juegos de Windows" \
  "epic" "Epic Games (Heroic)" "Inicia sesión en Epic Games / GOG con Proton" \
  "xbox" "Xbox Cloud Gaming" "Juega el catálogo de Xbox en la nube con mando" \
  "desktop" "Escritorio Linux" "Acceso libre al sistema y configuración")

# Cerrar lanzadores previos si el usuario está cambiando de plataforma
pkill -f "heroic" || true
pkill -f "chromium" || true

case "$CHOICE" in
  steam)
    steam -bigpicture &
    ;;
  epic)
    heroic --no-sandbox &
    ;;
  xbox)
    chromium-browser --no-sandbox --kiosk "https://www.xbox.com/play" &
    ;;
  desktop)
    xterm &
    ;;
  *)
    exit 0
    ;;
esac
