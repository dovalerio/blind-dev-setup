#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ambiente PHP' 'SECAO'

$cfg = Read-Config 'php'
if (-not $cfg) { exit 1 }

$phpVersion = Select-VersionMenu -Title 'Escolha a versao do PHP' -Options $cfg.versions

if ($phpVersion) {
    $ok = Install-WingetPackage -Name $phpVersion.name -WingetId $phpVersion.wingetId -TestCommand 'php'
    if (-not $ok) {
        Install-ChocoPackage -Name $phpVersion.name -ChocoId $phpVersion.chocoId -TestCommand 'php'
    }
    Refresh-EnvironmentVariables
}

if (-not (Test-CommandExists 'php')) {
    Write-AccessibleMessage 'PHP nao encontrado no PATH. Reinicie o terminal e execute novamente.' 'AVISO'
    exit 1
}

foreach ($tool in $cfg.tools) {
    switch ($tool.method) {
        'winget' { Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand }
        'choco'  { Install-ChocoPackage  -Name $tool.name -ChocoId  $tool.chocoId  -TestCommand $tool.testCommand }
        'script' {
            if (-not (Test-CommandExists $tool.testCommand)) {
                Write-AccessibleMessage "Instalando $($tool.name) via script oficial."
                $tmp = Join-Path $env:TEMP 'composer-setup.php'
                Invoke-WebRequest -Uri $tool.installerUrl -OutFile $tmp -UseBasicParsing
                php $tmp --install-dir="$env:ProgramFiles\Composer" --filename=composer 2>&1 |
                    ForEach-Object { Write-SetupLog $_ }
                Add-ToSystemPath "$env:ProgramFiles\Composer"
                Remove-Item $tmp -Force
                Write-AccessibleMessage "$($tool.name) instalado." 'OK'
            } else {
                Write-AccessibleMessage "$($tool.name) ja instalado." 'OK'
            }
        }
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Ambiente PHP' 'SECAO'
Test-Version 'php' -Arg '-v'
if (Test-CommandExists 'composer')  { Test-Version 'composer' }
if (Test-CommandExists 'symfony')   { Test-Version 'symfony' }
Write-AccessibleMessage 'Ambiente PHP concluido.' 'OK'
