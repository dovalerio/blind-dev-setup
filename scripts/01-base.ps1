#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Configuracao Base' 'SECAO'

$cfg = Read-Config 'base'
if (-not $cfg) { exit 1 }

function Install-Chocolatey {
    if (Test-CommandExists 'choco') {
        Write-AccessibleMessage "Chocolatey $(choco --version) ja instalado." 'OK'
        return
    }
    Write-AccessibleMessage 'Instalando Chocolatey. Aguarde.'
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Refresh-EnvironmentVariables
        Write-AccessibleMessage 'Chocolatey instalado com sucesso.' 'OK'
    } catch {
        Write-AccessibleMessage "Falha ao instalar Chocolatey: $_" 'ERRO'
    }
}

Write-AccessibleMessage 'Atualizando fontes do winget.'
winget source update --accept-source-agreements 2>&1 | Out-Null
Write-AccessibleMessage 'Fontes atualizadas.' 'OK'

Install-Chocolatey

foreach ($pkg in $cfg.packages) {
    $method = if ($pkg.method -eq 'choco') { 'choco' } else { 'winget' }
    if ($method -eq 'choco') {
        Install-ChocoPackage -Name $pkg.name -ChocoId $pkg.chocoId -TestCommand $pkg.testCommand
    } else {
        $ok = Install-WingetPackage -Name $pkg.name -WingetId $pkg.wingetId -TestCommand $pkg.testCommand
        if (-not $ok -and $pkg.chocoId) {
            Install-ChocoPackage -Name $pkg.name -ChocoId $pkg.chocoId -TestCommand $pkg.testCommand
        }
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Configuracao Base' 'SECAO'
foreach ($pkg in $cfg.packages | Where-Object { $_.testCommand }) {
    Test-Version -Command $pkg.testCommand
}
Write-AccessibleMessage 'Configuracao Base concluida.' 'OK'
