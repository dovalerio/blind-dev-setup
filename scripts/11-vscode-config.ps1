#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Write-AccessibleMessage 'VS Code - Configuracoes de acessibilidade NVDA' 'SECAO'

# ── Pre-requisito: VS Code instalado ──────────────────────────────────────────

if (-not (Test-CommandExists 'code')) {
    Write-AccessibleMessage 'VS Code nao encontrado. Execute a opcao 8 (IDEs) primeiro.' 'ERRO'
    exit 1
}
Write-AccessibleMessage "VS Code encontrado: $(code --version 2>&1 | Select-Object -First 1)" 'OK'

# ── Caminhos ──────────────────────────────────────────────────────────────────

$vsCodeUserDir  = Join-Path $env:APPDATA 'Code\User'
$extensionsDir  = Join-Path $env:USERPROFILE '.vscode\extensions'
$repoVSCodeDir  = Join-Path $script:RepoRoot 'vscode'

# ── Apresentar o que sera configurado ────────────────────────────────────────

Write-Host ''
Write-Host '============================================================'
Write-Host ' Configuracoes de acessibilidade VS Code + NVDA'
Write-Host '============================================================'
Write-Host ''
Write-Host 'O que sera aplicado:'
Write-Host ''
Write-Host '  [1] settings.json'
Write-Host '      Screen reader, breadcrumbs, sticky scroll,'
Write-Host '      sinais de audio, reducao de ruido para NVDA.'
Write-Host ''
Write-Host '  [2] keybindings.json'
Write-Host '      Alt+Down / Alt+Up  — proximo/anterior metodo (estilo IntelliJ)'
Write-Host '      Ctrl+F6            — contexto estrutural (breadcrumbs)'
Write-Host '      Ctrl+Alt+O         — painel Outline'
Write-Host '      Alt+H              — hover via teclado'
Write-Host '      Alt+F1 / Alt+F2    — ajuda e visao acessivel'
Write-Host ''
Write-Host '  [3] Extensao symbol-navigator'
Write-Host '      Navega entre metodos/classes sem popup.'
Write-Host '      Sem instalacao, sem build — carregada automaticamente.'
Write-Host ''
Write-Host '  Destinos:'
Write-Host "      Settings   : $vsCodeUserDir"
Write-Host "      Extensoes  : $extensionsDir"
Write-Host ''

$resp = (Read-Host 'Deseja aplicar as configuracoes de acessibilidade do VS Code? (s/n)').Trim().ToLower()
if ($resp -ne 's') {
    Write-AccessibleMessage 'Configuracoes VS Code ignoradas.' 'INFO'
    exit 0
}

# ── Garantir que os diretorios existem ───────────────────────────────────────

foreach ($dir in @($vsCodeUserDir, $extensionsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-AccessibleMessage "Diretorio criado: $dir" 'INFO'
    }
}

# ── Funcao de backup ─────────────────────────────────────────────────────────

function Backup-IfExists {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        $stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backup = "$FilePath.backup-$stamp"
        Copy-Item $FilePath $backup -Force
        Write-AccessibleMessage "Backup: $backup" 'INFO'
        return $backup
    }
    return $null
}

# ── [1] settings.json ────────────────────────────────────────────────────────

Write-AccessibleMessage 'Aplicando settings.json...' 'INFO'

$settingsTarget = Join-Path $vsCodeUserDir 'settings.json'
$settingsSrc    = Join-Path $repoVSCodeDir 'settings.json'

if (Test-Path $settingsTarget) {
    Write-Host ''
    Write-Host 'settings.json ja existe. Como deseja proceder?'
    Write-Host '  1 - Merge inteligente (adiciona/sobrepoe nossas configs, mantem o restante)'
    Write-Host '  2 - Substituir por completo (backup criado automaticamente)'
    Write-Host '  S - Pular'
    Write-Host ''

    $settingsChoice = (Read-Host 'Opcao').Trim().ToUpper()

    switch ($settingsChoice) {
        '1' {
            try {
                $existing = Get-Content $settingsTarget -Raw -Encoding UTF8 |
                            ConvertFrom-Json -AsHashtable -ErrorAction Stop
                $ours     = Get-Content $settingsSrc -Raw -Encoding UTF8 |
                            ConvertFrom-Json -AsHashtable -ErrorAction Stop

                Backup-IfExists $settingsTarget | Out-Null

                foreach ($key in $ours.Keys) {
                    $existing[$key] = $ours[$key]
                }

                $existing | ConvertTo-Json -Depth 10 | Set-Content $settingsTarget -Encoding UTF8
                Write-AccessibleMessage 'settings.json atualizado via merge.' 'OK'
            } catch {
                Write-AccessibleMessage "Falha no merge: $_. Tente a opcao 2 (substituir)." 'ERRO'
            }
        }
        '2' {
            Backup-IfExists $settingsTarget | Out-Null
            Copy-Item $settingsSrc $settingsTarget -Force
            Write-AccessibleMessage 'settings.json substituido.' 'OK'
        }
        'S' {
            Write-AccessibleMessage 'settings.json ignorado.' 'INFO'
        }
        default {
            Write-AccessibleMessage 'Opcao invalida. settings.json ignorado.' 'AVISO'
        }
    }
} else {
    Copy-Item $settingsSrc $settingsTarget -Force
    Write-AccessibleMessage 'settings.json criado.' 'OK'
}

# ── [2] keybindings.json ─────────────────────────────────────────────────────

Write-AccessibleMessage 'Aplicando keybindings.json...' 'INFO'

$keybindingsTarget = Join-Path $vsCodeUserDir 'keybindings.json'
$keybindingsSrc    = Join-Path $repoVSCodeDir 'keybindings.json'

if (Test-Path $keybindingsTarget) {
    Write-Host ''
    Write-Host 'keybindings.json ja existe.'
    Write-Host '  1 - Substituir (backup criado automaticamente)'
    Write-Host '  S - Pular'
    Write-Host ''

    $kbChoice = (Read-Host 'Opcao').Trim().ToUpper()

    if ($kbChoice -eq '1') {
        Backup-IfExists $keybindingsTarget | Out-Null
        Copy-Item $keybindingsSrc $keybindingsTarget -Force
        Write-AccessibleMessage 'keybindings.json substituido.' 'OK'
    } else {
        Write-AccessibleMessage 'keybindings.json ignorado.' 'INFO'
    }
} else {
    Copy-Item $keybindingsSrc $keybindingsTarget -Force
    Write-AccessibleMessage 'keybindings.json criado.' 'OK'
}

# ── [3] Extensao symbol-navigator ────────────────────────────────────────────

Write-AccessibleMessage 'Instalando extensao symbol-navigator...' 'INFO'

$extTarget = Join-Path $extensionsDir 'symbol-navigator-0.0.1'
$extSrc    = Join-Path $repoVSCodeDir 'symbol-navigator'

if (-not (Test-Path $extTarget)) {
    New-Item -ItemType Directory -Path $extTarget -Force | Out-Null
}

Copy-Item (Join-Path $extSrc 'package.json')  (Join-Path $extTarget 'package.json')  -Force
Copy-Item (Join-Path $extSrc 'extension.js')  (Join-Path $extTarget 'extension.js')  -Force

Write-AccessibleMessage 'Extensao symbol-navigator instalada.' 'OK'

# ── Resumo ────────────────────────────────────────────────────────────────────

Write-Host ''
Write-Host '============================================================'
Write-AccessibleMessage 'Configuracoes VS Code aplicadas com sucesso.' 'OK'
Write-Host '============================================================'
Write-Host ''
Write-Host 'PROXIMOS PASSOS:'
Write-Host ''
Write-Host '  1. Feche e reabra o VS Code para carregar a extensao.'
Write-Host ''
Write-Host '  2. Teste os atalhos em qualquer arquivo de codigo:'
Write-Host '     Alt+Down        — proximo metodo/classe'
Write-Host '     Alt+Up          — metodo/classe anterior'
Write-Host '     Ctrl+F6         — ver contexto atual (Classe > Metodo)'
Write-Host '     Ctrl+Alt+O      — abrir painel Outline'
Write-Host '     Alt+H           — documentacao do simbolo sob o cursor'
Write-Host ''
Write-Host '  3. Se backup foi criado, ele esta em:'
Write-Host "     $vsCodeUserDir"
Write-Host ''
