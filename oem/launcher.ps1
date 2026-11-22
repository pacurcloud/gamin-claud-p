Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Play-IntroAndLaunch {
    param (
        [string]$PlatformName,
        [string]$VideoPath,
        [scriptblock]$LaunchAction
    )

    $aviso = "AVISO DE SESIÓN TEMPORAL (gamin-claud-p)`n`n" +
             "Iniciarás sesión de forma normal en $PlatformName.`n" +
             "Recuerda que al detener o eliminar el contenedor Docker, los datos y sesiones temporales se borrarán.`n`n" +
             "¿Deseas continuar?"

    $res = [System.Windows.Forms.MessageBox]::Show($aviso, "Aviso - $PlatformName", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Information)
    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    # Cerrar otros lanzadores activos antes de cambiar
    Stop-Process -Name "steam", "EpicGamesLauncher", "XboxApp" -Force -ErrorAction SilentlyContinue

    # Reproducir intro MP4 en pantalla completa y esperar a que termine
    $vlcPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
    if ((Test-Path $VideoPath) -and (Test-Path $vlcPath)) {
        Start-Process -FilePath $vlcPath -ArgumentList "--fullscreen --play-and-exit --no-video-title-show `"$VideoPath`"" -Wait
    }

    # Ejecutar la plataforma en el modo solicitado
    & $LaunchAction
}

# Ventana principal del selector
$form = New-Object System.Windows.Forms.Form
$form.Text = "gamin-claud-p | Selector (Atajo: Ctrl + Alt + M)"
$form.Size = New-Object System.Drawing.Size(420, 310)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.TopMost = $true

$label = New-Object System.Windows.Forms.Label
$label.Text = "Selecciona una plataforma para iniciar:`n(Presiona Ctrl + Alt + M en cualquier momento para cambiar)"
$label.Location = New-Object System.Drawing.Point(20, 15)
$label.Size = New-Object System.Drawing.Size(370, 40)
$form.Controls.Add($label)

# Botón Xbox (App nativa Windows 11 + xbox.mp4)
$btnXbox = New-Object System.Windows.Forms.Button
$btnXbox.Text = "Xbox (App Nativa Windows 11)"
$btnXbox.Location = New-Object System.Drawing.Point(30, 70)
$btnXbox.Size = New-Object System.Drawing.Size(340, 45)
$btnXbox.Add_Click({
    $form.Hide()
    Play-IntroAndLaunch -PlatformName "Xbox" -VideoPath "C:\gamin-claud-p\xbox.mp4" -LaunchAction {
        Start-Process "xbox:"
    }
    $form.Close()
})
$form.Controls.Add($btnXbox)

# Botón Steam (Big Picture + steam.mp4)
$btnSteam = New-Object System.Windows.Forms.Button
$btnSteam.Text = "Steam (Modo Big Picture)"
$btnSteam.Location = New-Object System.Drawing.Point(30, 130)
$btnSteam.Size = New-Object System.Drawing.Size(340, 45)
$btnSteam.Add_Click({
    $form.Hide()
    Play-IntroAndLaunch -PlatformName "Steam Big Picture" -VideoPath "C:\gamin-claud-p\steam.mp4" -LaunchAction {
        $steamExe = "${env:ProgramFiles(x86)}\Steam\steam.exe"
        if (Test-Path $steamExe) {
            Start-Process $steamExe -ArgumentList "-bigpicture"
        } else {
            winget install --id=Valve.Steam -e --silent --accept-package-agreements --accept-source-agreements
            Start-Process $steamExe -ArgumentList "-bigpicture"
        }
    }
    $form.Close()
})
$form.Controls.Add($btnSteam)

# Botón Epic Games (Modo Normal + epic.mp4)
$btnEpic = New-Object System.Windows.Forms.Button
$btnEpic.Text = "Epic Games (Modo Normal)"
$btnEpic.Location = New-Object System.Drawing.Point(30, 190)
$btnEpic.Size = New-Object System.Drawing.Size(340, 45)
$btnEpic.Add_Click({
    $form.Hide()
    Play-IntroAndLaunch -PlatformName "Epic Games" -VideoPath "C:\gamin-claud-p\epic.mp4" -LaunchAction {
        $epicExe = "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
        if (Test-Path $epicExe) {
            Start-Process $epicExe
        } else {
            winget install --id=EpicGames.EpicGamesLauncher -e --silent --accept-package-agreements --accept-source-agreements
            Start-Process $epicExe
        }
    }
    $form.Close()
})
$form.Controls.Add($btnEpic)

[void]$form.ShowDialog()
