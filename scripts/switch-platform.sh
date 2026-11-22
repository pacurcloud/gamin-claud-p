#!/usr/bin/env bash
export DISPLAY=:1

AVISO="AVISO DE SESIÓN TEMPORAL (gamin-claud-p)\n\nPodrás iniciar sesión de forma normal en tu cuenta, pero recuerda que:\n• Todo inicio de sesión y datos temporales SE ELIMINARÁN al cerrar Docker.\n\n¿Deseas continuar?"

play_intro() {
  local video="$1"
  if [ -f "$video" ]; then
    mpv --fs --no-osc --really-quiet "$video"
  fi
}

while true; do
  CHOICE=$(zenity --list \
    --title="gamin-claud-p | Selector de Plataforma" \
    --text="Elige una plataforma (Atajo para cambiar en cualquier momento: Ctrl + Alt + M):" \
    --width=520 --height=300 \
    --column="ID" --column="Plataforma" --column="Modo" \
    "steam" "Steam" "Reproduce steam.mp4 y abre Steam en Big Picture" \
    "epic" "Epic Games" "Reproduce epic.mp4 y abre Heroic/Epic normal" \
    "xbox" "Xbox" "Reproduce xbox.mp4 y abre Xbox" \
    "terminal" "Terminal" "Ver consola de servicios")

  case "$CHOICE" in
    steam)
      zenity --question --title="Aviso de Sesión" --text="$AVISO" --width=420 || continue
      pkill -f "heroic" || true
      play_intro "/intros/steam.mp4"
      steam -bigpicture &
      exit 0
      ;;
    epic)
      zenity --question --title="Aviso de Sesión" --text="$AVISO" --width=420 || continue
      pkill -f "steam" || true
      play_intro "/intros/epic.mp4"
      heroic --no-sandbox &
      exit 0
      ;;
    xbox)
      zenity --question --title="Aviso de Sesión" --text="$AVISO" --width=420 || continue
      pkill -f "steam" || true
      pkill -f "heroic" || true
      play_intro "/intros/xbox.mp4"
      zenity --info --title="Xbox" --text="En un host Windows/KVM con GPU aquí arranca la app nativa de Xbox; en Linux sin GPU se requiere cliente Windows o nube." --width=420
      exit 0
      ;;
    terminal)
      xterm &
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
done
