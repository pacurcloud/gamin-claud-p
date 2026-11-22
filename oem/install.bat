@echo off
mkdir C:\gamin-claud-p
copy /Y "\\host.lan\Data\intros\*.mp4" C:\gamin-claud-p\ >nul 2>&1
copy /Y C:\OEM\launcher.ps1 C:\gamin-claud-p\launcher.ps1 >nul

:: Instalar VLC / mpv silenciosamente vía winget para reproducir los MP4 en pantalla completa sin bordes
winget install --id=VideoLAN.VLC -e --silent --accept-package-agreements --accept-source-agreements

:: Crear acceso directo en el Escritorio con atajo Ctrl+Alt+M para cambiar de plataforma
powershell -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('$env:USERPROFILE\Desktop\Cambiar Plataforma.lnk'); ^
   $s.TargetPath = 'powershell.exe'; ^
   $s.Arguments = '-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\gamin-claud-p\launcher.ps1'; ^
   $s.Hotkey = 'CTRL+ALT+M'; ^
   $s.Save()"

:: Ejecutar selector automáticamente al iniciar sesión en Windows 11
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "GaminClaudP" /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\gamin-claud-p\launcher.ps1" /f
