#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'helpers\common.ps1')

Ensure-Admin
Write-AccessibleMessage 'Ambiente Java' 'SECAO'

$cfg = Read-Config 'java'
if (-not $cfg) { exit 1 }

$jdk = Select-VersionMenu -Title 'Escolha a versao do JDK' -Options $cfg.jdk

if ($jdk) {
    $ok = Install-WingetPackage -Name $jdk.name -WingetId $jdk.wingetId
    if (-not $ok -and $jdk.chocoId) {
        Install-ChocoPackage -Name $jdk.name -ChocoId $jdk.chocoId
    }

    Refresh-EnvironmentVariables

    $correttoBase = 'C:\Program Files\Amazon Corretto'
    $temurinBase  = 'C:\Program Files\Eclipse Adoptium'
    $msJdkBase    = 'C:\Program Files\Microsoft'

    $javaHome = $null
    foreach ($base in @($correttoBase, $temurinBase, $msJdkBase)) {
        if (Test-Path $base) {
            $found = Find-InstallDir -BasePath $base -Pattern "jdk*$($jdk.version)*"
            if (-not $found) { $found = Find-InstallDir -BasePath $base -Pattern 'jdk*' }
            if ($found) { $javaHome = $found; break }
        }
    }

    if (-not $javaHome) {
        $javaCmd = Get-Command 'java' -ErrorAction SilentlyContinue
        if ($javaCmd) {
            $javaHome = Split-Path (Split-Path $javaCmd.Source -Parent) -Parent
        }
    }

    if ($javaHome) {
        Set-SystemEnvVar 'JAVA_HOME' $javaHome
        Add-ToSystemPath "$javaHome\bin"
        Write-AccessibleMessage "JAVA_HOME definido: $javaHome" 'OK'
    } else {
        Write-AccessibleMessage 'JAVA_HOME nao detectado. Reinicie o terminal e execute novamente.' 'AVISO'
    }
}

$buildTool = Select-VersionMenu -Title 'Escolha a ferramenta de build (Maven ou Gradle)' `
    -Options $cfg.buildTools -AllowSkip

if ($buildTool) {
    $ok = Install-WingetPackage -Name $buildTool.name -WingetId $buildTool.wingetId -TestCommand $buildTool.testCommand
    if (-not $ok -and $buildTool.chocoId) {
        Install-ChocoPackage -Name $buildTool.name -ChocoId $buildTool.chocoId -TestCommand $buildTool.testCommand
    }

    Refresh-EnvironmentVariables

    $toolCmd = Get-Command $buildTool.testCommand -ErrorAction SilentlyContinue
    if ($toolCmd) {
        $toolHome = Split-Path (Split-Path $toolCmd.Source -Parent) -Parent
        Set-SystemEnvVar $buildTool.envVar $toolHome
        if ($buildTool.envVarAlias) { Set-SystemEnvVar $buildTool.envVarAlias $toolHome }
        Write-AccessibleMessage "$($buildTool.envVar) definido: $toolHome" 'OK'
    }
}

Write-AccessibleMessage 'Validacao: Ambiente Java' 'SECAO'
Test-Version 'java' -Arg '-version'
if (Test-CommandExists 'mvn')    { Test-Version 'mvn' }
if (Test-CommandExists 'gradle') { Test-Version 'gradle' }
Write-AccessibleMessage 'Ambiente Java concluido.' 'OK'
