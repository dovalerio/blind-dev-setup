#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ferramentas de Acessibilidade'

Write-Log 'NVDA - Leitor de Telas (opcional, pode ja estar instalado)...'
$installNvda = Read-Host 'Instalar ou atualizar NVDA? (s/n)'
if ($installNvda -eq 's') {
    Install-Package -Name 'NVDA' -WingetId 'NVAccess.NVDA' -ChocoId 'nvda'
} else {
    Write-Log 'NVDA ignorado.' 'INFO'
}

Install-Package -Name 'Microsoft PowerToys' `
    -WingetId 'Microsoft.PowerToys' -ChocoId 'powertoys'

Install-Package -Name 'Accessibility Insights for Windows' `
    -WingetId 'Microsoft.AccessibilityInsights.forWindows'

Write-Log 'Copiando dicionarios NVDA para o perfil do usuario...'
$dictsSource = Join-Path $script:RepoRoot 'nvda\dicts'
$appDictsTarget  = "$env:APPDATA\nvda\speechDicts\appDicts"
$defaultDicTarget = "$env:APPDATA\nvda\speechDicts"

if (Test-Path $dictsSource) {
    if (-not (Test-Path $appDictsTarget)) {
        New-Item -ItemType Directory -Path $appDictsTarget -Force | Out-Null
    }
    $defaultDic = Join-Path $dictsSource 'default.dic'
    if (Test-Path $defaultDic) {
        Copy-Item $defaultDic (Join-Path $defaultDicTarget 'default.dic') -Force
        Write-Log 'default.dic copiado.' 'OK'
    }
    Get-ChildItem $dictsSource -Filter '*.dic' |
        Where-Object { $_.Name -ne 'default.dic' } |
        ForEach-Object {
            Copy-Item $_.FullName (Join-Path $appDictsTarget $_.Name) -Force
            Write-Log "Dicionario copiado: $($_.Name)" 'OK'
        }
    Write-Log 'Dicionarios NVDA instalados. Recarregue o NVDA para aplicar.' 'OK'
} else {
    Write-Log "Pasta de dicionarios nao encontrada: $dictsSource" 'AVISO'
}

Write-Section 'Validacao: Ferramentas de Acessibilidade'
Write-Log 'PowerToys e Accessibility Insights nao possuem comando CLI para validacao.' 'INFO'
Write-Log 'Verifique nos aplicativos instalados do Windows.' 'INFO'

Write-Log '=== Ferramentas de Acessibilidade concluido ===' 'OK'
