#Requires -Version 5.1
Set-StrictMode -Version Latest

$script:RepoRoot  = Split-Path $PSScriptRoot -Parent
$script:LogsDir   = Join-Path $script:RepoRoot 'logs'
$script:LogFile   = Join-Path $script:LogsDir "setup-$(Get-Date -Format 'yyyy-MM-dd').log"
$script:ConfigDir = Join-Path $script:RepoRoot 'configs'

if (-not (Test-Path $script:LogsDir)) {
    New-Item -ItemType Directory -Path $script:LogsDir -Force | Out-Null
}

# ---------------------------------------------------------------------------
# Logging e mensagens acessiveis
# ---------------------------------------------------------------------------

function Write-SetupLog {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message"
    Add-Content -Path $script:LogFile -Value $line -Encoding UTF8
}

function Write-AccessibleMessage {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'OK', 'AVISO', 'ERRO', 'SECAO')]
        [string]$Level = 'INFO'
    )
    Write-SetupLog -Message $Message -Level $Level
    switch ($Level) {
        'ERRO'  { Write-Host "ERRO: $Message"  -ForegroundColor Red    }
        'AVISO' { Write-Host "AVISO: $Message" -ForegroundColor Yellow }
        'OK'    { Write-Host "OK: $Message"    -ForegroundColor Green  }
        'SECAO' { Write-Host ''; Write-Host "=== $Message ===" }
        default { Write-Host "INFO: $Message" }
    }
}

# ---------------------------------------------------------------------------
# Admin e pre-requisitos
# ---------------------------------------------------------------------------

function Ensure-Admin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-AccessibleMessage 'Execute este script como Administrador.' 'ERRO'
        Write-AccessibleMessage 'Clique com o botao direito no PowerShell e escolha Executar como administrador.' 'ERRO'
        exit 1
    }
    Write-AccessibleMessage 'Privilegios de administrador confirmados.' 'OK'
}

function Test-Connectivity {
    try {
        $null = Invoke-WebRequest -Uri 'https://www.google.com' -TimeoutSec 8 -UseBasicParsing -ErrorAction Stop
        Write-AccessibleMessage 'Conectividade com a internet confirmada.' 'OK'
        return $true
    } catch {
        Write-AccessibleMessage 'Sem conexao com a internet. Verifique sua rede.' 'ERRO'
        return $false
    }
}

# ---------------------------------------------------------------------------
# Deteccao de comandos e pacotes
# ---------------------------------------------------------------------------

function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-WingetInstalled {
    param([string]$WingetId)
    try {
        $out = winget list --id $WingetId --accept-source-agreements 2>&1
        return ($LASTEXITCODE -eq 0) -and ($out -match [regex]::Escape($WingetId))
    } catch {
        return $false
    }
}

function Test-Version {
    param([string]$Command, [string]$Arg = '--version')
    try {
        $out = & $Command $Arg 2>&1 | Select-Object -First 1
        Write-AccessibleMessage "${Command}: $out" 'OK'
        return $true
    } catch {
        Write-AccessibleMessage "${Command} nao respondeu ou nao encontrado." 'AVISO'
        return $false
    }
}

# ---------------------------------------------------------------------------
# Instaladores
# ---------------------------------------------------------------------------

function Install-WingetPackage {
    param(
        [string]$Name,
        [string]$WingetId,
        [string]$TestCommand = '',
        [string[]]$ExtraArgs = @()
    )
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-AccessibleMessage "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if ($WingetId -and (Test-WingetInstalled $WingetId)) {
        Write-AccessibleMessage "$Name ja registrado no winget. Pulando." 'OK'
        return $true
    }
    Write-AccessibleMessage "Instalando $Name. Aguarde."
    try {
        $args = @('install', '--id', $WingetId, '--silent',
                  '--accept-package-agreements', '--accept-source-agreements') + $ExtraArgs
        winget @args 2>&1 | ForEach-Object { Write-SetupLog $_ }
        if ($LASTEXITCODE -in @(0, -1978335189, -1978335191)) {
            Write-AccessibleMessage "$Name instalado com sucesso." 'OK'
            return $true
        }
        throw "winget retornou codigo $LASTEXITCODE"
    } catch {
        Write-AccessibleMessage "Falha ao instalar $Name via winget: $_" 'ERRO'
        return $false
    }
}

function Install-ChocoPackage {
    param(
        [string]$Name,
        [string]$ChocoId,
        [string]$TestCommand = '',
        [string]$Version = ''
    )
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-AccessibleMessage "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'choco')) {
        Write-AccessibleMessage 'Chocolatey nao encontrado. Execute a opcao 1 (Configuracao base) primeiro.' 'ERRO'
        return $false
    }
    Write-AccessibleMessage "Instalando $Name via chocolatey. Aguarde."
    try {
        $versionArg = if ($Version) { "--version=$Version" } else { '' }
        choco install $ChocoId -y --no-progress $versionArg 2>&1 | ForEach-Object { Write-SetupLog $_ }
        Write-AccessibleMessage "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-AccessibleMessage "Falha ao instalar $Name via chocolatey: $_" 'ERRO'
        return $false
    }
}

function Install-NpmPackage {
    param([string]$Name, [string]$Package, [string]$TestCommand = '')
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-AccessibleMessage "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'npm')) {
        Write-AccessibleMessage 'npm nao encontrado. Execute a opcao 5 (Node.js) primeiro.' 'ERRO'
        return $false
    }
    Write-AccessibleMessage "Instalando $Name via npm. Aguarde."
    try {
        npm install -g $Package 2>&1 | ForEach-Object { Write-SetupLog $_ }
        Write-AccessibleMessage "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-AccessibleMessage "Falha ao instalar $Name via npm: $_" 'ERRO'
        return $false
    }
}

function Install-PipxPackage {
    param([string]$Name, [string]$Package, [string]$TestCommand = '')
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-AccessibleMessage "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'pipx')) {
        Write-AccessibleMessage 'pipx nao encontrado. Execute a opcao 4 (Python) primeiro.' 'ERRO'
        return $false
    }
    Write-AccessibleMessage "Instalando $Name via pipx. Aguarde."
    try {
        pipx install $Package 2>&1 | ForEach-Object { Write-SetupLog $_ }
        Write-AccessibleMessage "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-AccessibleMessage "Falha ao instalar $Name via pipx: $_" 'ERRO'
        return $false
    }
}

function Install-GoPackage {
    param([string]$Name, [string]$GoPackage, [string]$TestCommand = '')
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-AccessibleMessage "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'go')) {
        Write-AccessibleMessage 'go nao encontrado. Execute a opcao 12 (Golang) primeiro.' 'ERRO'
        return $false
    }
    Write-AccessibleMessage "Instalando $Name via go install. Aguarde."
    try {
        go install $GoPackage 2>&1 | ForEach-Object { Write-SetupLog $_ }
        Write-AccessibleMessage "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-AccessibleMessage "Falha ao instalar $Name via go install: $_" 'ERRO'
        return $false
    }
}

function Invoke-WithRetry {
    param(
        [scriptblock]$Action,
        [string]$Description = 'operacao',
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 5
    )
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try { & $Action; return } catch {
            if ($i -eq $MaxAttempts) {
                Write-AccessibleMessage "Falha em '$Description' apos $MaxAttempts tentativas: $_" 'ERRO'
                throw
            }
            Write-AccessibleMessage "Tentativa $i de $MaxAttempts falhou. Aguardando ${DelaySeconds} segundos." 'AVISO'
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

# ---------------------------------------------------------------------------
# Menu de selecao de versao
# ---------------------------------------------------------------------------

function Select-VersionMenu {
    param(
        [string]$Title,
        [array]$Options,
        [switch]$AllowSkip
    )
    Write-Host ''
    Write-Host '================================='
    Write-Host " $Title"
    Write-Host '================================='
    Write-Host ''
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "$i - $($Options[$i].name)"
    }
    if ($AllowSkip) { Write-Host 'S - Pular esta etapa' }
    Write-Host ''
    while ($true) {
        $raw = (Read-Host 'Digite a opcao').Trim().ToUpper()
        if ($AllowSkip -and $raw -eq 'S') {
            Write-AccessibleMessage 'Etapa ignorada.' 'INFO'
            return $null
        }
        if ($raw -match '^\d+$') {
            $idx = [int]$raw
            if ($idx -ge 0 -and $idx -lt $Options.Count) {
                Write-AccessibleMessage "Selecionado: $($Options[$idx].name)" 'OK'
                return $Options[$idx]
            }
        }
        $max = $Options.Count - 1
        $hint = if ($AllowSkip) { "de 0 a $max ou S para pular" } else { "de 0 a $max" }
        Write-AccessibleMessage "Opcao invalida. Digite um numero $hint." 'AVISO'
    }
}

# ---------------------------------------------------------------------------
# PATH e variaveis de ambiente
# ---------------------------------------------------------------------------

function Refresh-EnvironmentVariables {
    $m = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $u = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$m;$u"
    Write-AccessibleMessage 'Variaveis de ambiente atualizadas na sessao atual.' 'OK'
}

function Add-ToSystemPath {
    param([string]$PathToAdd)
    if (-not (Test-Path $PathToAdd)) {
        Write-AccessibleMessage "Caminho nao existe, ignorado: $PathToAdd" 'AVISO'
        return
    }
    $current = [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';' |
               Where-Object { $_ -ne '' }
    if ($PathToAdd -in $current) {
        Write-AccessibleMessage "PATH ja contem: $PathToAdd" 'OK'
        return
    }
    [Environment]::SetEnvironmentVariable('Path', ($current + $PathToAdd) -join ';', 'Machine')
    $env:Path = "$env:Path;$PathToAdd"
    Write-AccessibleMessage "Adicionado ao PATH do sistema: $PathToAdd" 'OK'
}

function Set-SystemEnvVar {
    param([string]$Name, [string]$Value)
    [Environment]::SetEnvironmentVariable($Name, $Value, 'Machine')
    [System.Environment]::SetEnvironmentVariable($Name, $Value, 'Process')
    Write-AccessibleMessage "Variavel definida: $Name = $Value" 'OK'
}

function Find-InstallDir {
    param([string]$BasePath, [string]$Pattern)
    return Get-ChildItem $BasePath -Directory -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -like $Pattern } |
           Sort-Object Name -Descending |
           Select-Object -First 1 -ExpandProperty FullName
}

# ---------------------------------------------------------------------------
# Configuracao JSON
# ---------------------------------------------------------------------------

function Read-Config {
    param([string]$Name)
    $path = Join-Path $script:ConfigDir "$Name.json"
    if (-not (Test-Path $path)) {
        Write-AccessibleMessage "Arquivo de config nao encontrado: $path" 'ERRO'
        return $null
    }
    return Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

# ---------------------------------------------------------------------------
# Export
# ---------------------------------------------------------------------------

function Invoke-Export {
    $exportsDir = Join-Path $script:RepoRoot 'exports'
    if (-not (Test-Path $exportsDir)) { New-Item -ItemType Directory $exportsDir -Force | Out-Null }
    $stamp = Get-Date -Format 'yyyy-MM-dd_HHmm'

    Write-AccessibleMessage 'Exportando lista de pacotes winget...'
    $exportFile = Join-Path $exportsDir "winget-export-$stamp.json"
    winget export -o $exportFile --accept-source-agreements 2>&1 | Out-Null
    Write-AccessibleMessage "Exportado em: $exportFile" 'OK'

    $envFile = Join-Path $exportsDir "environment-$stamp.txt"
    @(
        "JAVA_HOME=$env:JAVA_HOME"
        "MAVEN_HOME=$env:MAVEN_HOME"
        "GRADLE_HOME=$env:GRADLE_HOME"
        "PYTHON_HOME=$env:PYTHON_HOME"
        "GOPATH=$env:GOPATH"
        "GOROOT=$env:GOROOT"
        "Path=$env:Path"
    ) | Set-Content $envFile -Encoding UTF8
    Write-AccessibleMessage "Snapshot de variaveis exportado em: $envFile" 'OK'
}
