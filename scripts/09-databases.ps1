#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Bancos de Dados' 'SECAO'

$cfg = Read-Config 'databases'
if (-not $cfg) { exit 1 }

$pg = Select-VersionMenu -Title 'Escolha a versao do PostgreSQL' `
    -Options $cfg.postgresql -AllowSkip

if ($pg) {
    if ($pg.method -eq 'winget') {
        Install-WingetPackage -Name $pg.name -WingetId $pg.wingetId
    } else {
        Install-ChocoPackage -Name $pg.name -ChocoId $pg.chocoId -TestCommand 'psql'
    }
}

$mysql = Select-VersionMenu -Title 'Escolha a versao do MySQL' `
    -Options $cfg.mysql -AllowSkip

if ($mysql) {
    if ($mysql.method -eq 'winget') {
        Install-WingetPackage -Name $mysql.name -WingetId $mysql.wingetId -TestCommand 'mysql'
    } else {
        Install-ChocoPackage -Name $mysql.name -ChocoId $mysql.chocoId -TestCommand 'mysql'
    }
}

foreach ($tool in $cfg.optional) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        switch ($tool.method) {
            'winget' { Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand }
            'choco'  { Install-ChocoPackage  -Name $tool.name -ChocoId  $tool.chocoId  -TestCommand $tool.testCommand }
            'docker' {
                if (Test-CommandExists 'docker') {
                    Write-AccessibleMessage "Baixando imagem Docker: $($tool.dockerImage). Aguarde."
                    docker pull $tool.dockerImage 2>&1 | ForEach-Object { Write-SetupLog $_ }
                    Write-AccessibleMessage "$($tool.name) disponivel via Docker. Execute: docker run -p $($tool.port):$($tool.port) $($tool.dockerImage)" 'OK'
                } else {
                    Write-AccessibleMessage 'Docker nao encontrado. Instale a opcao 7 (Cloud e DevOps) primeiro.' 'AVISO'
                }
            }
        }
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

foreach ($tool in $cfg.tools) {
    Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand
}

Write-AccessibleMessage 'Validacao: Bancos de Dados' 'SECAO'
if (Test-CommandExists 'psql')  { Test-Version 'psql' -Arg '--version' }
if (Test-CommandExists 'mysql') { Test-Version 'mysql' -Arg '--version' }
Write-AccessibleMessage 'Bancos de Dados concluido.' 'OK'
