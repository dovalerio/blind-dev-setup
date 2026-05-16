#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ferramentas de IA'

if (-not (Test-CommandExists 'node')) {
    Write-Log 'Node.js nao encontrado. Executando 12-node-env.ps1 primeiro...' 'AVISO'
    & (Join-Path $PSScriptRoot '12-node-env.ps1')
    Refresh-Path
}

if (-not (Test-CommandExists 'pipx')) {
    Write-Log 'pipx nao encontrado. Executando 11-python-env.ps1 primeiro...' 'AVISO'
    & (Join-Path $PSScriptRoot '11-python-env.ps1')
    Refresh-Path
}

Write-Log 'Instalando ferramentas de IA via npm...'

Install-NpmGlobal -Name 'Claude Code' `
    -Package '@anthropic-ai/claude-code' -TestCommand 'claude'

Install-NpmGlobal -Name 'Gemini CLI' `
    -Package '@google/gemini-cli' -TestCommand 'gemini'

Install-NpmGlobal -Name 'Codex CLI' `
    -Package '@openai/codex' -TestCommand 'codex'

Write-Log 'Instalando GitHub Copilot via extensao gh...'
if (Test-CommandExists 'gh') {
    if (-not (gh extension list 2>&1 | Select-String 'gh-copilot')) {
        gh extension install github/gh-copilot 2>&1 | ForEach-Object { Write-Log "  gh: $_" }
        Write-Log 'GitHub Copilot CLI instalado. Use: gh copilot' 'OK'
    } else {
        Write-Log 'GitHub Copilot CLI ja instalado. Pulando.' 'OK'
    }
} else {
    Write-Log 'gh nao encontrado. Execute 01-package-managers.ps1 primeiro.' 'AVISO'
}

Write-Log 'Instalando ferramentas de IA via pipx...'

Install-PipxPackage -Name 'Aider' -Package 'aider-chat' -TestCommand 'aider'
Install-PipxPackage -Name 'OpenAI CLI' -Package 'openai' -TestCommand 'openai'

Write-Log 'Ollama (opcional - execucao local de modelos)...'
$installOllama = Read-Host 'Instalar Ollama para modelos locais? (s/n)'
if ($installOllama -eq 's') {
    Install-Package -Name 'Ollama' -WingetId 'Ollama.Ollama' -TestCommand 'ollama'
} else {
    Write-Log 'Ollama ignorado.' 'INFO'
}

Refresh-Path

Write-Section 'Validacao: Ferramentas de IA'
Test-Version 'claude'
Test-Version 'gemini'
Test-Version 'codex'
Test-Version 'aider'
if (Test-CommandExists 'ollama') { Test-Version 'ollama' -Arg '--version' }

Write-Log '=== Ferramentas de IA concluido ===' 'OK'
