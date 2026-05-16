#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Gerenciadores de Pacotes'

function Install-Chocolatey {
    if (Test-CommandExists 'choco') {
        Write-Log "Chocolatey $(choco --version) ja instalado." 'OK'
        return
    }
    Write-Log 'Instalando Chocolatey...'
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $installScript = (New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Invoke-Expression $installScript
        Refresh-Path
        if (Test-CommandExists 'choco') {
            Write-Log "Chocolatey $(choco --version) instalado com sucesso." 'OK'
        } else {
            Write-Log 'Chocolatey instalado mas nao encontrado no PATH. Reinicie o terminal.' 'AVISO'
        }
    } catch {
        Write-Log "Falha ao instalar Chocolatey: $_" 'ERRO'
    }
}

Write-Log 'Atualizando fontes do winget...'
winget source update --accept-source-agreements 2>&1 | Out-Null
Write-Log 'Fontes do winget atualizadas.' 'OK'

Install-Chocolatey

Install-Package -Name 'Git' `
    -WingetId 'Git.Git' -ChocoId 'git' -TestCommand 'git'

Install-Package -Name 'GitHub CLI' `
    -WingetId 'GitHub.cli' -ChocoId 'gh' -TestCommand 'gh'

Refresh-Path

Write-Section 'Validacao: Gerenciadores de Pacotes'
Test-Version 'git'
Test-Version 'gh'
if (Test-CommandExists 'choco') { Test-Version 'choco' -Arg '--version' }

Write-Log '=== Gerenciadores de Pacotes concluido ===' 'OK'
