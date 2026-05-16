#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ambiente PHP'

Install-Package -Name 'PHP' `
    -WingetId 'PHP.PHP' -ChocoId 'php' -TestCommand 'php'

Refresh-Path

if (-not (Test-CommandExists 'php')) {
    Write-Log 'PHP nao encontrado no PATH apos instalacao. Reinicie o terminal.' 'AVISO'
    exit 1
}

Write-Log 'Instalando Composer...'
if (Test-CommandExists 'composer') {
    Write-Log "Composer $(composer --version 2>&1 | Select-Object -First 1) ja instalado." 'OK'
} else {
    $installerPath = Join-Path $env:TEMP 'composer-setup.php'
    try {
        Write-Log 'Baixando instalador do Composer...'
        Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile $installerPath -UseBasicParsing
        php $installerPath --install-dir="$env:ProgramFiles\Composer" --filename=composer 2>&1 |
            ForEach-Object { Write-Log "  composer-setup: $_" }
        Add-ToSystemPath "$env:ProgramFiles\Composer"
        Refresh-Path
        Write-Log 'Composer instalado com sucesso.' 'OK'
    } catch {
        Write-Log "Falha ao instalar Composer: $_" 'ERRO'
    } finally {
        if (Test-Path $installerPath) { Remove-Item $installerPath -Force }
    }
}

Write-Section 'Validacao: Ambiente PHP'
Test-Version 'php' -Arg '-v'
Test-Version 'composer'

Write-Log '=== Ambiente PHP concluido ===' 'OK'
