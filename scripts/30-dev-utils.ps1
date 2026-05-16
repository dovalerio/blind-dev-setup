#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Utilitarios de Desenvolvimento'

Install-Package -Name 'jq' `
    -WingetId 'jqlang.jq' -ChocoId 'jq' -TestCommand 'jq'

Install-Package -Name 'yq' `
    -WingetId 'MikeFarah.yq' -ChocoId 'yq' -TestCommand 'yq'

Install-Package -Name 'Postman' `
    -WingetId 'Postman.Postman' -ChocoId 'postman'

Install-Package -Name 'DBeaver Community' `
    -WingetId 'dbeaver.dbeaver' -ChocoId 'dbeaver'

Write-Log 'Docker Desktop (opcional - requer virtualizacao habilitada)...'
$installDocker = Read-Host 'Instalar Docker Desktop? (s/n)'
if ($installDocker -eq 's') {
    Install-Package -Name 'Docker Desktop' `
        -WingetId 'Docker.DockerDesktop' -ChocoId 'docker-desktop' -TestCommand 'docker'
    Write-Log 'Docker Desktop instalado. Reinicie o computador para concluir a configuracao.' 'AVISO'
} else {
    Write-Log 'Docker Desktop ignorado.' 'INFO'
}

Refresh-Path

Write-Section 'Validacao: Utilitarios de Desenvolvimento'
Test-Version 'jq'
Test-Version 'yq'
if (Test-CommandExists 'docker') { Test-Version 'docker' }

Write-Log '=== Utilitarios de Desenvolvimento concluido ===' 'OK'
