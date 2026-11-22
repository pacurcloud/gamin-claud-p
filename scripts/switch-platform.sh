#!/usr/bin/env bash
export DISPLAY=:1

AVISO_SESION="AVISO DE SESIÓN TEMPORAL (gamin-claud-p)\n\nPodrás iniciar sesión de forma normal en tu cuenta para descargar y jugar tus títulos en /games, pero ten en cuenta que:\n• Todo inicio de sesión, credenciales y caché temporal en este contenedor SE ELIMINARÁN al detener o cerrar Docker.\n• Al terminar tu sesión en Docker, tu cuenta quedará cerrada automáticamente.\n\n¿Deseas continuar e iniciar sesión ahora?"

while true; do
  CHOICE=$(zenity --list \
    --title="gamin-claud-p | Selector de Plataforma Nativa" \
    --text="Elige qué aplicación iniciar (Atajo para cambiar en cualquier momento: Ctrl + Alt + M):" \
    --width=580 --height=340 \
    --ok-label="Iniciar plataforma" \
    --cancel-label="Cerrar menú" \
    --column="ID" --column="Plataforma" --column="Modo de ejecución" \
    "steam" "Steam (App Nativa)" "Cliente nativo Steam Big Picture (descarga juegos en /games)" \
    "epic" "Epic Games (App Nativa)" "Cliente nativo Heroic para tu biblioteca de Epic Games" \
    "xbox" "Xbox PC (App Nativa Windows)" "Arranca VM Windows con la app nativa de Xbox (sin navegador ni Game Pass)" \
    "desktop" "Escritorio Linux" "Terminal y administración del contenedor")

  case "$CHOICE" in
    steam)
      zenity --question \
        --title="Aviso de Sesión Temporal - Steam" \
        --text="$AVISO_SESION" \
        --width=480 \
        --ok-label="Aceptar e iniciar sesión" \
        --cancel-label="Volver" || continue

      pkill -f "heroic" || true
      pkill -f "qemu-system" || true
      steam -bigpicture &
      exit 0
      ;;

    epic)
      zenity --question \
        --title="Aviso de Sesión Temporal - Epic Games" \
        --text="$AVISO_SESION" \
        --width=480 \
        --ok-label="Aceptar e iniciar sesión" \
        --cancel-label="Volver" || continue

      pkill -f "steam" || true
      pkill -f "qemu-system" || true
      heroic --no-sandbox &
      exit 0
      ;;

    xbox)
      zenity --question \
        --title="Aviso de Sesión Temporal - Xbox App (Windows)" \
        --text="$AVISO_SESION" \
        --width=480 \
        --ok-label="Aceptar e iniciar sesión" \
        --cancel-label="Volver" || continue

      if [ ! -f "/games/windows-xbox.qcow2" ]; then
        zenity --warning \
          --title="Falta imagen de Windows para Xbox App" \
          --width=480 \
          --text="Microsoft no tiene app nativa de Xbox para Linux.\n\nPara ejecutar la app nativa de Xbox sin navegador:\n1. Coloca tu disco virtual de Windows con la app de Xbox instalada en:\n   /games/windows-xbox.qcow2\n2. Vuelve a seleccionar esta opción."
        continue
      fi

      pkill -f "steam" || true
      pkill -f "heroic" || true
      qemu-system-x86_64 \
        -enable-kvm \
        -m 8192 \
        -cpu host \
        -smp 4 \
        -drive file=/games/windows-xbox.qcow2,format=qcow2,if=virtio \
        -device virtio-vga-gl \
        -display gtk,gl=on,full-screen=on \
        -audiodev pa,id=snd0,server=unix:/tmp/pulse-socket \
        -device ich9-intel-hda -device hda-output,audiodev=snd0 \
        -usb -device usb-tablet &
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
