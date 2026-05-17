#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'IDEs' 'SECAO'

$cfg = Read-Config 'ides'
if (-not $cfg) { exit 1 }

foreach ($group in $cfg.groups) {
    $selected = Select-VersionMenu -Title "Escolha a edicao: $($group.title)" `
        -Options $group.options -AllowSkip

    if ($selected) {
        $ok = Install-WingetPackage -Name $selected.name -WingetId $selected.wingetId
        if (-not $ok -and $selected.chocoId) {
            Install-ChocoPackage -Name $selected.name -ChocoId $selected.chocoId
        }
    }
}

foreach ($tool in $cfg.standalone) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

Write-AccessibleMessage 'IDEs concluido.' 'OK'
