#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ambiente Node.js' 'SECAO'

$cfg = Read-Config 'node'
if (-not $cfg) { exit 1 }

$nodeVersion = Select-VersionMenu -Title 'Escolha a versao do Node.js' -Options $cfg.versions

if ($nodeVersion) {
    $ok = Install-WingetPackage -Name $nodeVersion.name -WingetId $nodeVersion.wingetId -TestCommand 'node'
    if (-not $ok -and $nodeVersion.chocoId) {
        Install-ChocoPackage -Name $nodeVersion.name -ChocoId $nodeVersion.chocoId -TestCommand 'node'
    }
    Refresh-EnvironmentVariables
}

if (-not (Test-CommandExists 'node')) {
    Write-AccessibleMessage 'Node.js nao encontrado no PATH. Reinicie o terminal e execute novamente.' 'AVISO'
    exit 1
}

Write-AccessibleMessage 'Atualizando npm.'
npm install -g npm@latest 2>&1 | ForEach-Object { Write-SetupLog $_ }

foreach ($tool in $cfg.tools) {
    switch ($tool.method) {
        'winget' { Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand }
        'npm'    { Install-NpmPackage    -Name $tool.name -Package  $tool.package  -TestCommand $tool.testCommand }
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Ambiente Node.js' 'SECAO'
Test-Version 'node'
Test-Version 'npm'
foreach ($tool in $cfg.tools | Where-Object { $_.testCommand }) {
    if (Test-CommandExists $tool.testCommand) { Test-Version $tool.testCommand }
}
Write-AccessibleMessage 'Ambiente Node.js concluido.' 'OK'
