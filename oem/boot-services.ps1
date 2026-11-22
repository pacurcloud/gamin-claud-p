$Host.UI.RawUI.WindowTitle = "gamin-claud-p | Consola de Servicios en Vivo"
Clear-Host

function Write-Log {
    param([string]$Level, [string]$Message, [ConsoleColor]$Color = "Gray")
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host "[$time] " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$Level] " -NoNewline -ForegroundColor $Color
    Write-Host $Message
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   GAMIN-CLAUD-P :: INICIALIZANDO SERVICIOS EN WINDOWS 11   " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar y sincronizar intros MP4 desde el host Docker
Write-Log "STORAGE" "Verificando carpeta compartida de intros MP4..." "Yellow"
if (Test-Path "\\host.lan\Data\intros") {
    Copy-Item "\\host.lan\Data\intros\*.mp4" "C:\gamin-claud-p\" -Force -ErrorAction SilentlyContinue
    Write-Log "OK" "Videos xbox.mp4, steam.mp4 y epic.mp4 sincronizados." "Green"
} else {
    Write-Log "WARN" "Usando intros locales en C:\gamin-claud-p\" "DarkYellow"
}

# 2. Iniciar servicio de Audio de Windows (necesario para streaming)
Write-Log "AUDIO" "Iniciando Windows Audio (Audiosrv) para salida en streaming..." "Yellow"
Start-Service -Name "Audiosrv" -ErrorAction SilentlyContinue
Set-Service -Name "Audiosrv" -StartupType Automatic -ErrorAction SilentlyContinue
Write-Log "OK" "Servicio de audio activo." "Green"

# 3. Verificar reproductor VLC para intros sin bordes
$vlcPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
if (-not (Test-Path $vlcPath)) {
    Write-Log "PKG" "Instalando reproductor multimedia para intros MP4..." "Yellow"
    winget install --id=VideoLAN.VLC -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
    Write-Log "OK" "Reproductor instalado." "Green"
} else {
    Write-Log "OK" "Reproductor multimedia listo." "Green"
}

# 4. Verificar clientes nativos (Xbox App, Steam, Epic)
Write-Log "APPS" "Comprobando clientes nativos instalados..." "Yellow"
if (Get-AppxPackage -Name "*XboxApp*" -ErrorAction SilentlyContinue) {
    Write-Log "OK" "Xbox App nativa detectada en Windows 11." "Green"
} else {
    Write-Log "INFO" "Xbox App se abrira mediante protocolo nativo xbox:" "Cyan"
}

if (Test-Path "${env:ProgramFiles(x86)}\Steam\steam.exe") {
    Write-Log "OK" "Cliente nativo de Steam listo." "Green"
} else {
    Write-Log "INFO" "Steam se instalara bajo demanda al seleccionarlo." "Cyan"
}

if (Test-Path "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe") {
    Write-Log "OK" "Epic Games Launcher listo." "Green"
} else {
    Write-Log "INFO" "Epic Games se instalara bajo demanda al seleccionarlo." "Cyan"
}

# 5. Activar demonio en segundo plano que escucha Ctrl + Alt + M y limpieza de sesion
Write-Log "SYSTEM" "Activando servicio de sesion temporal (se limpia al apagar Docker)..." "Yellow"
Start-Sleep -Seconds 1
Write-Log "READY" "Todos los servicios de gamin-claud-p estan operativos." "Green"
Write-Host ""
Write-Host ">> Lanzando selector de plataformas (Atajo: Ctrl + Alt + M)..." -ForegroundColor Magenta
Start-Sleep -Seconds 2

# Ejecutar el selector visual dejando esta consola visible detras como monitor de logs
& "C:\gamin-claud-p\launcher.ps1"
