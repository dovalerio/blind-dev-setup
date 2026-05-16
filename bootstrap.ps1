#Requires -Version 7.0
Set-StrictMode -Version Latest

$scriptRoot = $PSScriptRoot
. (Join-Path $scriptRoot 'scripts\00-common.ps1')

function Invoke-PreChecks {
    Write-Section 'Verificacoes iniciais'

    Assert-Administrator

    if (-not (Test-CommandExists 'winget')) {
        Write-Log 'winget nao encontrado.' 'ERRO'
        Write-Log 'Instale o App Installer pela Microsoft Store ou atualize o Windows.' 'ERRO'
        exit 1
    }
    Write-Log "winget $(winget --version) encontrado." 'OK'

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Log "PowerShell 7+ necessario. Versao atual: $($PSVersionTable.PSVersion)" 'ERRO'
        Write-Log 'Execute em um terminal comum: winget install Microsoft.PowerShell' 'AVISO'
        exit 1
    }
    Write-Log "PowerShell $($PSVersionTable.PSVersion) confirmado." 'OK'

    Write-Log "Log desta sessao: $script:LogFile" 'INFO'
}

function Show-Menu {
    Write-Host ''
    Write-Host '=== BLIND DEV SETUP ==='
    Write-Host '1 - Configuracao base (gerenciadores de pacotes e ferramentas essenciais)'
    Write-Host '2 - Ferramentas de IA (Claude Code, Copilot, Gemini, Aider)'
    Write-Host '3 - Ambiente Java (Corretto 21, Maven, Gradle, IntelliJ IDEA)'
    Write-Host '4 - Ambiente Python (3.12, pip, pipx, poetry, ruff)'
    Write-Host '5 - Ambiente Node.js (LTS, pnpm, yarn)'
    Write-Host '6 - Ambiente PHP (PHP, Composer)'
    Write-Host '7 - Ferramentas de acessibilidade (NVDA, PowerToys)'
    Write-Host '8 - Utilitarios de desenvolvimento (Docker, DBeaver, jq, yq)'
    Write-Host '9 - Instalar tudo'
    Write-Host '0 - Sair'
    Write-Host ''
    Write-Host -NoNewline 'Digite o numero e pressione Enter: '
}

function Invoke-Script {
    param([string]$FileName)
    $path = Join-Path $scriptRoot "scripts\$FileName"
    if (-not (Test-Path $path)) {
        Write-Log "Script nao encontrado: $path" 'ERRO'
        return
    }
    Write-Section "Iniciando: $FileName"
    try {
        & $path
    } catch {
        Write-Log "Erro ao executar ${FileName}: $_" 'ERRO'
    }
}

function Invoke-All {
    Invoke-Script '01-package-managers.ps1'
    Invoke-Script '02-core-tools.ps1'
    Invoke-Script '03-ai-tools.ps1'
    Invoke-Script '10-java-env.ps1'
    Invoke-Script '11-python-env.ps1'
    Invoke-Script '12-node-env.ps1'
    Invoke-Script '13-php-env.ps1'
    Invoke-Script '20-accessibility-tools.ps1'
    Invoke-Script '30-dev-utils.ps1'
}

Invoke-PreChecks

$running = $true
while ($running) {
    Show-Menu
    $choice = (Read-Host).Trim()
    switch ($choice) {
        '1' {
            Invoke-Script '01-package-managers.ps1'
            Invoke-Script '02-core-tools.ps1'
        }
        '2' { Invoke-Script '03-ai-tools.ps1' }
        '3' { Invoke-Script '10-java-env.ps1' }
        '4' { Invoke-Script '11-python-env.ps1' }
        '5' { Invoke-Script '12-node-env.ps1' }
        '6' { Invoke-Script '13-php-env.ps1' }
        '7' { Invoke-Script '20-accessibility-tools.ps1' }
        '8' { Invoke-Script '30-dev-utils.ps1' }
        '9' { Invoke-All }
        '0' {
            Write-Log 'Encerrando. Consulte os logs em: logs\'
            $running = $false
        }
        default {
            Write-Log "Opcao invalida: '$choice'. Digite um numero de 0 a 9." 'AVISO'
        }
    }
    if ($running) {
        Write-Host ''
        Write-Host -NoNewline 'Pressione Enter para voltar ao menu...'
        Read-Host | Out-Null
    }
}
