#!/usr/bin/env bash
export DISPLAY=:1

AVISO_SESION="AVISO DE SESIÓN TEMPORAL (gamin-claud-p)\n\nPodrás iniciar sesión de manera normal en tu cuenta, pero ten en cuenta que:\n• Todo inicio de sesión, caché y datos temporales en este contenedor SE ELIMINARÁN al detener o cerrar Docker.\n• No dejes sesiones abiertas en equipos compartidos ni guardes contraseñas esperando que persistan.\n\n¿Deseas continuar e iniciar sesión ahora?"

while true; do
  CHOICE=$(zenity --list \
    --title="gamin-claud-p | Selector de Plataforma" \
    --text="Elige una plataforma (Atajo para cambiar: Ctrl + Alt + M):" \
    --width=540 --height=330 \
    --ok-label="Seleccionar" \
    --cancel-label="Salir del menú" \
    --column="ID" --column="Plataforma" --column="Descripción" \
    "steam" "Steam (Big Picture)" "Inicio de sesión normal (se borra al cerrar Docker)" \
    "epic" "Epic Games (Heroic)" "Inicio de sesión normal (se borra al cerrar Docker)" \
    "xbox" "Xbox Cloud Gaming" "Inicio de sesión normal en navegador (se borra al cerrar Docker)" \
    "desktop" "Escritorio Linux" "Acceso libre al entorno gráfico y configuración")

  case "$CHOICE" in
    steam)
      zenity --question \
        --title="Aviso de Sesión Temporal - Steam" \
        --text="$AVISO_SESION" \
        --width=460 \
        --ok-label="Continuar e iniciar sesión" \
        --cancel-label="Volver" || continue

      pkill -f "heroic" || true
      pkill -f "chromium" || true
      steam -bigpicture &
      exit 0
      ;;
    epic)
      zenity --question \
        --title="Aviso de Sesión Temporal - Epic Games" \
        --text="$AVISO_SESION" \
        --width=460 \
        --ok-label="Continuar e iniciar sesión" \
        --cancel-label="Volver" || continue

      pkill -f "steam" || true
      pkill -f "chromium" || true
      heroic --no-sandbox &
      exit 0
      ;;
    xbox)
      zenity --question \
        --title="Aviso de Sesión Temporal - Xbox Cloud" \
        --text="$AVISO_SESION" \
        --width=460 \
        --ok-label="Continuar e iniciar sesión" \
        --cancel-label="Volver" || continue

      pkill -f "steam" || true
      pkill -f "heroic" || true
      chromium-browser --no-sandbox --kiosk --incognito "https://www.xbox.com/play" &
      exit 0
      ;;
    desktop)
      xterm &
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
done
