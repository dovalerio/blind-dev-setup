#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ferramentas Essenciais'

Install-Package -Name 'Windows Terminal' `
    -WingetId 'Microsoft.WindowsTerminal' -ChocoId 'microsoft-windows-terminal'

Install-Package -Name 'PowerShell 7' `
    -WingetId 'Microsoft.PowerShell' -ChocoId 'powershell-core' -TestCommand 'pwsh'

Install-Package -Name '7-Zip' `
    -WingetId '7zip.7zip' -ChocoId '7zip' -TestCommand '7z'

Install-Package -Name 'wget' `
    -WingetId 'JernejSimoncic.Wget' -ChocoId 'wget' -TestCommand 'wget'

Install-Package -Name 'Visual Studio Code' `
    -WingetId 'Microsoft.VisualStudioCode' -ChocoId 'vscode' -TestCommand 'code'

Install-Package -Name 'Notepad++' `
    -WingetId 'Notepad++.Notepad++' -ChocoId 'notepadplusplus'

Install-Package -Name 'Python Launcher' `
    -WingetId 'Python.Launcher' -ChocoId ''

Refresh-Path

Write-Section 'Validacao: Ferramentas Essenciais'
Test-Version 'pwsh'
Test-Version '7z' -Arg 'i'
Test-Version 'code'
if (Test-CommandExists 'wget') { Test-Version 'wget' -Arg '--version' }

Write-Log '=== Ferramentas Essenciais concluido ===' 'OK'
