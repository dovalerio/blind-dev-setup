#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Cloud e DevOps' 'SECAO'

$cfg = Read-Config 'cloud'
if (-not $cfg) { exit 1 }

foreach ($tool in $cfg.required) {
    $ok = Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand
    if (-not $ok -and $tool.chocoId) {
        Install-ChocoPackage -Name $tool.name -ChocoId $tool.chocoId -TestCommand $tool.testCommand
    }
}

foreach ($tool in $cfg.optional) {
    $resp = Read-Host "Instalar $($tool.name)? (s/n)"
    if ($resp.Trim().ToLower() -eq 's') {
        $ok = Install-WingetPackage -Name $tool.name -WingetId $tool.wingetId -TestCommand $tool.testCommand
        if (-not $ok -and $tool.chocoId) {
            Install-ChocoPackage -Name $tool.name -ChocoId $tool.chocoId -TestCommand $tool.testCommand
        }
        if ($tool.name -eq 'Docker Desktop') {
            Write-AccessibleMessage 'Docker Desktop instalado. Reinicie o computador para concluir a configuracao.' 'AVISO'
        }
    } else {
        Write-AccessibleMessage "$($tool.name) ignorado." 'INFO'
    }
}

Refresh-EnvironmentVariables

Write-AccessibleMessage 'Validacao: Cloud e DevOps' 'SECAO'
foreach ($tool in $cfg.required + $cfg.optional | Where-Object { $_.testCommand }) {
    if (Test-CommandExists $tool.testCommand) { Test-Version $tool.testCommand }
}
Write-AccessibleMessage 'Cloud e DevOps concluido.' 'OK'
