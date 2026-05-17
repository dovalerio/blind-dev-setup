#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ferramentas de Acessibilidade' 'SECAO'

$cfg = Read-Config 'accessibility'
if (-not $cfg) { exit 1 }

foreach ($tool in $cfg.optional) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

foreach ($tool in $cfg.required) {
    Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId
}

Write-AccessibleMessage 'Instalando dicionarios NVDA.' 'SECAO'
$dictsSource    = Join-Path $script:RepoRoot 'nvda\dicts'
$appDictsTarget = "$env:APPDATA\nvda\speechDicts\appDicts"
$defaultTarget  = "$env:APPDATA\nvda\speechDicts"

if (Test-Path $dictsSource) {
    if (-not (Test-Path $appDictsTarget)) {
        New-Item -ItemType Directory -Path $appDictsTarget -Force | Out-Null
    }

    $defaultDic = Join-Path $dictsSource 'default.dic'
    if (Test-Path $defaultDic) {
        Copy-Item $defaultDic (Join-Path $defaultTarget 'default.dic') -Force
        Write-AccessibleMessage 'default.dic copiado.' 'OK'
    }

    Get-ChildItem $dictsSource -Filter '*.dic' |
        Where-Object { $_.Name -ne 'default.dic' } |
        ForEach-Object {
            Copy-Item $_.FullName (Join-Path $appDictsTarget $_.Name) -Force
            Write-AccessibleMessage "Dicionario copiado: $($_.Name)" 'OK'
        }

    Write-AccessibleMessage 'Dicionarios instalados. Recarregue o NVDA para aplicar as mudancas.' 'OK'
} else {
    Write-AccessibleMessage "Pasta de dicionarios nao encontrada: $dictsSource" 'AVISO'
}

Write-AccessibleMessage 'Acessibilidade concluida.' 'OK'
