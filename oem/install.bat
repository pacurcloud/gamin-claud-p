@echo off
title Instalando servicios base de gamin-claud-p...
echo [INIT] Creando directorio C:\gamin-claud-p...
mkdir C:\gamin-claud-p >nul 2>&1

echo [INIT] Copiando intros MP4 y scripts al sistema...
copy /Y "\\host.lan\Data\intros\*.mp4" C:\gamin-claud-p\ >nul 2>&1
copy /Y C:\OEM\launcher.ps1 C:\gamin-claud-p\launcher.ps1 >nul
copy /Y C:\OEM\boot-services.ps1 C:\gamin-claud-p\boot-services.ps1 >nul

echo [INIT] Registrando acceso directo Ctrl + Alt + M en el Escritorio...
powershell -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('$env:USERPROFILE\Desktop\Cambiar Plataforma.lnk'); ^
   $s.TargetPath = 'powershell.exe'; ^
   $s.Arguments = '-ExecutionPolicy Bypass -File C:\gamin-claud-p\launcher.ps1'; ^
   $s.Hotkey = 'CTRL+ALT+M'; ^
   $s.Save()"

echo [INIT] Configurando terminal visible al iniciar sesion en Windows 11...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "GaminClaudP_Boot" /t REG_SZ /d "powershell.exe -NoExit -ExecutionPolicy Bypass -File C:\gamin-claud-p\boot-services.ps1" /f

echo [OK] Instalacion inicial completada.
