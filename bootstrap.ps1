#Requires -Version 5.1
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'helpers\common.ps1')

function Invoke-PreChecks {
    Write-AccessibleMessage 'Blind Dev Setup iniciando.' 'SECAO'
    Ensure-Admin

    if (-not (Test-CommandExists 'winget')) {
        Write-AccessibleMessage 'winget nao encontrado. Instale o App Installer via Microsoft Store.' 'ERRO'
        exit 1
    }
    Write-AccessibleMessage "winget $(winget --version) disponivel." 'OK'

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-AccessibleMessage "PowerShell $($PSVersionTable.PSVersion) detectado. Versao 7 ou superior necessaria." 'AVISO'
        Write-AccessibleMessage 'Tentando instalar PowerShell 7 via winget...' 'INFO'
        try {
            winget install --id Microsoft.PowerShell --silent `
                --accept-package-agreements --accept-source-agreements 2>&1 |
                ForEach-Object { Write-SetupLog $_ }

            if ($LASTEXITCODE -in @(0, -1978335189, -1978335191)) {
                Write-AccessibleMessage 'PowerShell 7 instalado com sucesso.' 'OK'
            } else {
                Write-AccessibleMessage "winget retornou codigo $LASTEXITCODE. Tente instalar manualmente." 'ERRO'
                Write-AccessibleMessage 'Comando: winget install Microsoft.PowerShell' 'INFO'
                exit 1
            }
        } catch {
            Write-AccessibleMessage "Falha ao instalar PowerShell 7: $_" 'ERRO'
            Write-AccessibleMessage 'Instale manualmente: winget install Microsoft.PowerShell' 'INFO'
            exit 1
        }

        Write-Host ''
        Write-Host '============================================================'
        Write-AccessibleMessage 'PROXIMOS PASSOS:' 'SECAO'
        Write-Host '  1. Feche este terminal.'
        Write-Host '  2. Abra o PowerShell 7 (procure por "PowerShell 7" no menu Iniciar'
        Write-Host '     ou execute "pwsh" em um novo terminal).'
        Write-Host '  3. Execute novamente: .\bootstrap.ps1'
        Write-Host '============================================================'
        Write-Host ''
        exit 0
    }
    Write-AccessibleMessage "PowerShell $($PSVersionTable.PSVersion) confirmado." 'OK'

    if (-not (Test-Connectivity)) { exit 1 }

    Write-AccessibleMessage "Log desta sessao: $script:LogFile" 'INFO'
}

function Show-MainMenu {
    Write-Host ''
    Write-Host '================================='
    Write-Host ' Blind Dev Setup'
    Write-Host '================================='
    Write-Host ''
    Write-Host ' 1 - Configuracao base'
    Write-Host ' 2 - Ferramentas de IA'
    Write-Host ' 3 - Ambiente Java'
    Write-Host ' 4 - Ambiente Python'
    Write-Host ' 5 - Ambiente Node.js'
    Write-Host ' 6 - Ambiente PHP'
    Write-Host ' 7 - Cloud e DevOps'
    Write-Host ' 8 - IDEs'
    Write-Host ' 9 - Bancos de dados'
    Write-Host '10 - Acessibilidade'
    Write-Host '11 - Configuracoes VS Code (acessibilidade NVDA)'
    Write-Host '12 - Ambiente Golang'
    Write-Host '13 - Instalar tudo'
    Write-Host ' E - Exportar configuracao atual'
    Write-Host ' 0 - Sair'
    Write-Host ''
    Write-Host -NoNewline 'Digite uma opcao: '
}

function Invoke-Script {
    param([string]$File)
    $path = Join-Path $PSScriptRoot "scripts\$File"
    if (-not (Test-Path $path)) {
        Write-AccessibleMessage "Script nao encontrado: $path" 'ERRO'
        return
    }
    Write-AccessibleMessage "Iniciando: $File" 'SECAO'
    try {
        & $path
    } catch {
        Write-AccessibleMessage "Erro em ${File}: $_" 'ERRO'
    }
}

function Invoke-All {
    '01-base.ps1', '02-ai-tools.ps1', '03-java.ps1', '04-python.ps1',
    '05-node.ps1', '06-php.ps1', '07-cloud.ps1', '08-ides.ps1',
    '09-databases.ps1', '10-accessibility.ps1', '11-vscode-config.ps1',
    '12-golang.ps1' | ForEach-Object { Invoke-Script $_ }
}

Invoke-PreChecks

$running = $true
while ($running) {
    Show-MainMenu
    $choice = (Read-Host).Trim().ToUpper()
    switch ($choice) {
        '1'  { Invoke-Script '01-base.ps1' }
        '2'  { Invoke-Script '02-ai-tools.ps1' }
        '3'  { Invoke-Script '03-java.ps1' }
        '4'  { Invoke-Script '04-python.ps1' }
        '5'  { Invoke-Script '05-node.ps1' }
        '6'  { Invoke-Script '06-php.ps1' }
        '7'  { Invoke-Script '07-cloud.ps1' }
        '8'  { Invoke-Script '08-ides.ps1' }
        '9'  { Invoke-Script '09-databases.ps1' }
        '10' { Invoke-Script '10-accessibility.ps1' }
        '11' { Invoke-Script '11-vscode-config.ps1' }
        '12' { Invoke-Script '12-golang.ps1' }
        '13' { Invoke-All }
        'E'  { Invoke-Export }
        '0'  { Write-AccessibleMessage 'Encerrando. Consulte logs em: logs\'; $running = $false }
        default { Write-AccessibleMessage "Opcao invalida: '$choice'. Digite um numero de 0 a 13." 'AVISO' }
    }
    if ($running) {
        Write-Host ''
        Write-Host -NoNewline 'Pressione Enter para voltar ao menu...'
        Read-Host | Out-Null
    }
}
