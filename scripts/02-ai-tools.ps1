#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ferramentas de IA' 'SECAO'

$cfg = Read-Config 'ai'
if (-not $cfg) { exit 1 }

if (-not (Test-CommandExists 'node')) {
    Write-AccessibleMessage 'Node.js nao encontrado. Executando 05-node.ps1 primeiro.' 'AVISO'
    & (Join-Path $PSScriptRoot '05-node.ps1')
    Refresh-EnvironmentVariables
}

if (-not (Test-CommandExists 'pipx')) {
    Write-AccessibleMessage 'pipx nao encontrado. Executando 04-python.ps1 primeiro.' 'AVISO'
    & (Join-Path $PSScriptRoot '04-python.ps1')
    Refresh-EnvironmentVariables
}

foreach ($tool in $cfg.npm) {
    Install-NpmPackage -Name $tool.name -Package $tool.package -TestCommand $tool.testCommand
}

foreach ($tool in $cfg.pipx) {
    Install-PipxPackage -Name $tool.name -Package $tool.package -TestCommand $tool.testCommand
}

if (Test-CommandExists 'gh') {
    Write-AccessibleMessage 'Instalando GitHub Copilot CLI via extensao gh.'
    if (-not (gh extension list 2>&1 | Select-String 'gh-copilot')) {
        gh extension install github/gh-copilot 2>&1 | ForEach-Object { Write-SetupLog $_ }
        Write-AccessibleMessage 'GitHub Copilot instalado. Use: gh copilot' 'OK'
    } else {
        Write-AccessibleMessage 'GitHub Copilot ja instalado.' 'OK'
    }
} else {
    Write-AccessibleMessage 'gh nao encontrado. Execute a opcao 1 (Configuracao base) primeiro.' 'AVISO'
}

foreach ($tool in $cfg.wingetOptional) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Ferramentas de IA' 'SECAO'
foreach ($tool in $cfg.npm + $cfg.pipx | Where-Object { $_.testCommand }) {
    Test-Version -Command $tool.testCommand
}
Write-AccessibleMessage 'Ferramentas de IA concluidas.' 'OK'
