#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ambiente Golang' 'SECAO'

$cfg = Read-Config 'golang'
if (-not $cfg) { exit 1 }

$goVersion = Select-VersionMenu -Title 'Escolha a versao do Go' -Options $cfg.versions -AllowSkip

if ($goVersion) {
    $ok = Install-WingetPackage -Name $goVersion.name -WingetId $goVersion.wingetId -TestCommand $goVersion.testCommand
    if (-not $ok -and $goVersion.chocoId) {
        Install-ChocoPackage -Name $goVersion.name -ChocoId $goVersion.chocoId -TestCommand $goVersion.testCommand
    }
    Refresh-EnvironmentVariables
}

if (-not (Test-CommandExists 'go')) {
    Write-AccessibleMessage 'Go nao encontrado no PATH. Reinicie o terminal e execute novamente.' 'AVISO'
    exit 1
}

$gopath = [Environment]::GetEnvironmentVariable('GOPATH', 'User')
if (-not $gopath) {
    $gopath = Join-Path $env:USERPROFILE 'go'
    [Environment]::SetEnvironmentVariable('GOPATH', $gopath, 'User')
    $env:GOPATH = $gopath
    Write-AccessibleMessage "GOPATH definido: $gopath" 'OK'
} else {
    Write-AccessibleMessage "GOPATH ja configurado: $gopath" 'OK'
}

$gobin = Join-Path $gopath 'bin'
if (-not (Test-Path $gobin)) { New-Item -ItemType Directory -Path $gobin -Force | Out-Null }
Add-ToSystemPath $gobin

Refresh-EnvironmentVariables

foreach ($tool in $cfg.tools) {
    switch ($tool.method) {
        'go'     { Install-GoPackage      -Name $tool.name -GoPackage $tool.goPackage -TestCommand $tool.testCommand }
        'winget' { Install-WingetPackage  -Name $tool.name -WingetId  $tool.wingetId  -TestCommand $tool.testCommand }
    }
}

foreach ($tool in $cfg.optional) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        switch ($tool.method) {
            'go'     { Install-GoPackage      -Name $tool.name -GoPackage $tool.goPackage -TestCommand $tool.testCommand }
            'winget' { Install-WingetPackage  -Name $tool.name -WingetId  $tool.wingetId  -TestCommand $tool.testCommand }
        }
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Ambiente Golang' 'SECAO'
Test-Version 'go' -Arg 'version'
foreach ($tool in $cfg.tools | Where-Object { $_.testCommand }) {
    if (Test-CommandExists $tool.testCommand) { Test-Version $tool.testCommand }
}
Write-AccessibleMessage 'Ambiente Golang concluido.' 'OK'
