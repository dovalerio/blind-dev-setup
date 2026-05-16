#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ambiente Node.js'

Install-Package -Name 'Node.js LTS' `
    -WingetId 'OpenJS.NodeJS.LTS' -ChocoId 'nodejs-lts' -TestCommand 'node'

Refresh-Path

if (-not (Test-CommandExists 'node')) {
    Write-Log 'Node.js nao encontrado no PATH apos instalacao. Reinicie o terminal.' 'AVISO'
    exit 1
}

Write-Log 'Atualizando npm...'
npm install -g npm@latest 2>&1 | ForEach-Object { Write-Log "  npm: $_" }

Install-NpmGlobal -Name 'pnpm' -Package 'pnpm' -TestCommand 'pnpm'
Install-NpmGlobal -Name 'yarn' -Package 'yarn' -TestCommand 'yarn'

Refresh-Path

Write-Section 'Validacao: Ambiente Node.js'
Test-Version 'node'
Test-Version 'npm'
Test-Version 'pnpm'
Test-Version 'yarn'

Write-Log '=== Ambiente Node.js concluido ===' 'OK'
