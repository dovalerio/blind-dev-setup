#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ambiente Python'

Install-Package -Name 'Python 3.12' `
    -WingetId 'Python.Python.3.12' -ChocoId 'python312' -TestCommand 'python'

Refresh-Path

if (-not (Test-CommandExists 'python')) {
    Write-Log 'Python nao encontrado no PATH apos instalacao. Reinicie o terminal.' 'AVISO'
    exit 1
}

Write-Log 'Atualizando pip...'
python -m pip install --upgrade pip 2>&1 | ForEach-Object { Write-Log "  pip: $_" }

Write-Log 'Instalando pipx...'
if (-not (Test-CommandExists 'pipx')) {
    python -m pip install --user pipx 2>&1 | ForEach-Object { Write-Log "  pip: $_" }
    python -m pipx ensurepath 2>&1 | ForEach-Object { Write-Log "  pipx: $_" }
    Refresh-Path
    Write-Log 'pipx instalado.' 'OK'
} else {
    Write-Log 'pipx ja instalado.' 'OK'
}

Write-Log 'Instalando virtualenv...'
if (-not (Test-CommandExists 'virtualenv')) {
    pip install virtualenv 2>&1 | ForEach-Object { Write-Log "  pip: $_" }
    Write-Log 'virtualenv instalado.' 'OK'
} else {
    Write-Log 'virtualenv ja instalado.' 'OK'
}

Install-PipxPackage -Name 'Poetry' -Package 'poetry' -TestCommand 'poetry'
Install-PipxPackage -Name 'Ruff' -Package 'ruff' -TestCommand 'ruff'
Install-PipxPackage -Name 'Black' -Package 'black' -TestCommand 'black'

Refresh-Path

Write-Section 'Validacao: Ambiente Python'
Test-Version 'python'
Test-Version 'pip'
Test-Version 'pipx'
Test-Version 'poetry'
Test-Version 'ruff'
Test-Version 'black'

Write-Log '=== Ambiente Python concluido ===' 'OK'
