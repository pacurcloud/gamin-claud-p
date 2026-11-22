$Host.UI.RawUI.WindowTitle = "gamin-claud-p | Cargando servicios..."
[Console]::CursorVisible = $false
Clear-Host

function Show-LoadingStep {
    param(
        [string]$TaskLabel,
        [int]$Percent,
        [scriptblock]$Action
    )

    $job = Start-Job -ScriptBlock $Action
    $frames = @("|", "/", "-", "\")
    $i = 0

    while ($job.State -eq "Running") {
        $spin = $frames[$i % $frames.Count]
        $filled = [math]::Floor($Percent / 5)
        $bar = ("#" * $filled) + ("-" * (20 - $filled))
        Write-Host "`r  [$spin] Cargando servicios... [$bar] $Percent% - $TaskLabel   " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 150
        $i++
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-Null
    Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host "                    GAMIN - CLAUD - P                   " -ForegroundColor White
Write-Host "  ======================================================" -ForegroundColor DarkCyan
Write-Host ""

# 1. Sincronizar intros MP4
Show-LoadingStep -TaskLabel "Sincronizando intros (Xbox / Steam / Epic)" -Percent 25 -Action {
    New-Item -ItemType Directory -Path "C:\gamin-claud-p" -Force | Out-Null
    if (Test-Path "\\host.lan\Data\intros") {
        Copy-Item "\\host.lan\Data\intros\*.mp4" "C:\gamin-claud-p\" -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
}

# 2. Activar servicio de audio
Show-LoadingStep -TaskLabel "Iniciando audio para streaming" -Percent 55 -Action {
    Start-Service -Name "Audiosrv" -ErrorAction SilentlyContinue
    Set-Service -Name "Audiosrv" -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# 3. Preparar reproductor de intros
Show-LoadingStep -TaskLabel "Preparando motor de video sin bordes" -Percent 85 -Action {
    $vlcPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
    if (-not (Test-Path $vlcPath)) {
        winget install --id=VideoLAN.VLC -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
    }
}

# 4. Completado
Show-LoadingStep -TaskLabel "Verificando sesion temporal y controles" -Percent 100 -Action {
    Start-Sleep -Seconds 1
}

Write-Host "`r  [OK] Cargando servicios... [####################] 100% - ¡Listo!          " -ForegroundColor Green
Write-Host ""
[Console]::CursorVisible = $true
Start-Sleep -Seconds 1

# Abrir el selector de plataformas (Xbox, Steam Big Picture, Epic)
& "C:\gamin-claud-p\launcher.ps1"
