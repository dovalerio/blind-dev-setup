#Requires -Version 7.0
Set-StrictMode -Version Latest

$script:RepoRoot = if ($PSScriptRoot -match 'scripts$') {
    Split-Path $PSScriptRoot -Parent
} else {
    $PSScriptRoot
}

$script:LogsDir    = Join-Path $script:RepoRoot 'logs'
$script:LogFile    = Join-Path $script:LogsDir "setup-$(Get-Date -Format 'yyyy-MM-dd').log"
$script:ConfigFile = Join-Path $script:RepoRoot 'configs\packages.json'

if (-not (Test-Path $script:LogsDir)) {
    New-Item -ItemType Directory -Path $script:LogsDir -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'OK', 'AVISO', 'ERRO')]
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp][$Level] $Message"
    Add-Content -Path $script:LogFile -Value $line -Encoding UTF8
    switch ($Level) {
        'ERRO'  { Write-Host $line -ForegroundColor Red }
        'AVISO' { Write-Host $line -ForegroundColor Yellow }
        'OK'    { Write-Host $line -ForegroundColor Green }
        default { Write-Host $line }
    }
}

function Write-Section {
    param([string]$Title)
    Write-Log ''
    Write-Log "=== $Title ==="
}

function Test-Administrator {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Administrator {
    if (-not (Test-Administrator)) {
        Write-Log 'Este script precisa ser executado como Administrador.' 'ERRO'
        Write-Log 'Clique com o botao direito no PowerShell e escolha Executar como administrador.' 'ERRO'
        exit 1
    }
    Write-Log 'Privilegios de administrador confirmados.' 'OK'
}

function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-WingetInstalled {
    param([string]$WingetId)
    try {
        $output = winget list --id $WingetId --accept-source-agreements 2>&1
        return ($LASTEXITCODE -eq 0) -and ($output -match [regex]::Escape($WingetId))
    } catch {
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
        try {
            & $Action
            return
        } catch {
            if ($i -eq $MaxAttempts) {
                Write-Log "Falha em '$Description' apos $MaxAttempts tentativas: $_" 'ERRO'
                throw
            }
            Write-Log "Tentativa $i/$MaxAttempts falhou para '$Description'. Aguardando ${DelaySeconds}s..." 'AVISO'
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Install-WithWinget {
    param(
        [string]$Name,
        [string]$WingetId,
        [string]$TestCommand = '',
        [string[]]$ExtraArgs = @()
    )
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-Log "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if ($WingetId -and (Test-WingetInstalled $WingetId)) {
        Write-Log "$Name ja esta instalado via winget. Pulando." 'OK'
        return $true
    }
    Write-Log "Instalando $Name via winget..."
    try {
        $argList = @('install', '--id', $WingetId, '--silent',
                     '--accept-package-agreements', '--accept-source-agreements') + $ExtraArgs
        winget @argList 2>&1 | ForEach-Object { Write-Log "  winget: $_" }
        if ($LASTEXITCODE -in @(0, -1978335189, -1978335191)) {
            Write-Log "$Name instalado com sucesso." 'OK'
            return $true
        }
        throw "winget retornou codigo $LASTEXITCODE"
    } catch {
        Write-Log "Falha ao instalar $Name via winget: $_" 'ERRO'
        return $false
    }
}

function Install-WithChoco {
    param(
        [string]$Name,
        [string]$ChocoId,
        [string]$TestCommand = ''
    )
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-Log "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'choco')) {
        Write-Log 'Chocolatey nao encontrado. Execute o script 01-package-managers.ps1 primeiro.' 'ERRO'
        return $false
    }
    Write-Log "Instalando $Name via chocolatey..."
    try {
        choco install $ChocoId -y --no-progress 2>&1 | ForEach-Object { Write-Log "  choco: $_" }
        Write-Log "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-Log "Falha ao instalar $Name via chocolatey: $_" 'ERRO'
        return $false
    }
}

function Install-Package {
    param(
        [string]$Name,
        [string]$WingetId = '',
        [string]$ChocoId = '',
        [string]$TestCommand = '',
        [string[]]$WingetArgs = @()
    )
    $ok = $false
    if ($WingetId) {
        $ok = Install-WithWinget -Name $Name -WingetId $WingetId -TestCommand $TestCommand -ExtraArgs $WingetArgs
    }
    if (-not $ok -and $ChocoId) {
        Write-Log "Tentando fallback para chocolatey..." 'AVISO'
        $ok = Install-WithChoco -Name $Name -ChocoId $ChocoId -TestCommand $TestCommand
    }
    return $ok
}

function Install-NpmGlobal {
    param([string]$Name, [string]$Package, [string]$TestCommand = '')
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-Log "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'npm')) {
        Write-Log 'npm nao encontrado. Execute o script 12-node-env.ps1 primeiro.' 'ERRO'
        return $false
    }
    Write-Log "Instalando $Name via npm..."
    try {
        npm install -g $Package 2>&1 | ForEach-Object { Write-Log "  npm: $_" }
        Write-Log "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-Log "Falha ao instalar $Name via npm: $_" 'ERRO'
        return $false
    }
}

function Install-PipxPackage {
    param([string]$Name, [string]$Package, [string]$TestCommand = '')
    if ($TestCommand -and (Test-CommandExists $TestCommand)) {
        Write-Log "$Name ja esta instalado. Pulando." 'OK'
        return $true
    }
    if (-not (Test-CommandExists 'pipx')) {
        Write-Log 'pipx nao encontrado. Execute o script 11-python-env.ps1 primeiro.' 'ERRO'
        return $false
    }
    Write-Log "Instalando $Name via pipx..."
    try {
        pipx install $Package 2>&1 | ForEach-Object { Write-Log "  pipx: $_" }
        Write-Log "$Name instalado com sucesso." 'OK'
        return $true
    } catch {
        Write-Log "Falha ao instalar $Name via pipx: $_" 'ERRO'
        return $false
    }
}

function Add-ToSystemPath {
    param([string]$PathToAdd)
    if (-not (Test-Path $PathToAdd)) {
        Write-Log "Caminho nao existe, nao adicionado ao PATH: $PathToAdd" 'AVISO'
        return
    }
    $current = [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';' |
               Where-Object { $_ -ne '' }
    if ($PathToAdd -in $current) {
        Write-Log "PATH ja contem: $PathToAdd" 'OK'
        return
    }
    $newPath = ($current + $PathToAdd) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
    $env:Path = "$env:Path;$PathToAdd"
    Write-Log "Adicionado ao PATH do sistema: $PathToAdd" 'OK'
}

function Set-SystemEnvVar {
    param([string]$Name, [string]$Value)
    [Environment]::SetEnvironmentVariable($Name, $Value, 'Machine')
    [System.Environment]::SetEnvironmentVariable($Name, $Value, 'Process')
    Write-Log "Variavel definida: $Name = $Value" 'OK'
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Test-Version {
    param([string]$Command, [string]$Arg = '--version')
    try {
        $out = & $Command $Arg 2>&1 | Select-Object -First 1
        Write-Log "${Command}: $out" 'OK'
        return $true
    } catch {
        Write-Log "${Command} nao respondeu ou nao encontrado." 'AVISO'
        return $false
    }
}

function Find-InstallDir {
    param([string]$BasePath, [string]$Pattern)
    return Get-ChildItem $BasePath -Directory -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -like $Pattern } |
           Sort-Object Name -Descending |
           Select-Object -First 1 -ExpandProperty FullName
}

function Read-PackageConfig {
    if (-not (Test-Path $script:ConfigFile)) {
        Write-Log "Arquivo de configuracao nao encontrado: $script:ConfigFile" 'AVISO'
        return $null
    }
    return Get-Content $script:ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
}
