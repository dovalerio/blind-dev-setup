#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ambiente Python' 'SECAO'

$cfg = Read-Config 'python'
if (-not $cfg) { exit 1 }

$pyVersion = Select-VersionMenu -Title 'Escolha a versao do Python' -Options $cfg.versions

if ($pyVersion) {
    $ok = Install-WingetPackage -Name $pyVersion.name -WingetId $pyVersion.wingetId -TestCommand $pyVersion.testCommand
    if (-not $ok -and $pyVersion.chocoId) {
        Install-ChocoPackage -Name $pyVersion.name -ChocoId $pyVersion.chocoId
    }
    Refresh-EnvironmentVariables
}

if (-not (Test-CommandExists 'python')) {
    Write-AccessibleMessage 'Python nao encontrado no PATH. Reinicie o terminal e execute novamente.' 'AVISO'
    exit 1
}

Write-AccessibleMessage 'Atualizando pip.'
python -m pip install --upgrade pip 2>&1 | ForEach-Object { Write-SetupLog $_ }

Write-AccessibleMessage 'Instalando pipx.'
if (-not (Test-CommandExists 'pipx')) {
    python -m pip install --user pipx 2>&1 | ForEach-Object { Write-SetupLog $_ }
    python -m pipx ensurepath 2>&1 | ForEach-Object { Write-SetupLog $_ }
    Refresh-EnvironmentVariables
    Write-AccessibleMessage 'pipx instalado.' 'OK'
} else {
    Write-AccessibleMessage 'pipx ja instalado.' 'OK'
}

foreach ($tool in $cfg.tools) {
    switch ($tool.method) {
        'winget' { Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand }
        'pipx'   { Install-PipxPackage  -Name $tool.name -Package  $tool.package  -TestCommand $tool.testCommand }
        'pip'    {
            if (-not (Test-CommandExists $tool.testCommand)) {
                Write-AccessibleMessage "Instalando $($tool.name) via pip."
                pip install $tool.package 2>&1 | ForEach-Object { Write-SetupLog $_ }
                Write-AccessibleMessage "$($tool.name) instalado." 'OK'
            } else {
                Write-AccessibleMessage "$($tool.name) ja instalado." 'OK'
            }
        }
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Ambiente Python' 'SECAO'
Test-Version 'python'
Test-Version 'pip'
Test-Version 'pipx'
foreach ($tool in $cfg.tools | Where-Object { $_.testCommand }) {
    if (Test-CommandExists $tool.testCommand) { Test-Version $tool.testCommand }
}
Write-AccessibleMessage 'Ambiente Python concluido.' 'OK'
