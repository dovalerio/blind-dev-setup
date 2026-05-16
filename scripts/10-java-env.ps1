#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '00-common.ps1')

Assert-Administrator
Write-Section 'Ambiente Java'

Install-Package -Name 'Amazon Corretto 21 JDK' `
    -WingetId 'Amazon.Corretto.21.JDK' -ChocoId 'corretto21jdk'

Install-Package -Name 'Apache Maven' `
    -WingetId 'Apache.Maven' -ChocoId 'maven' -TestCommand 'mvn'

Install-Package -Name 'Gradle' `
    -WingetId 'Gradle.Gradle' -ChocoId 'gradle' -TestCommand 'gradle'

Install-Package -Name 'IntelliJ IDEA Community' `
    -WingetId 'JetBrains.IntelliJIDEA.Community' -ChocoId 'intellijidea-community'

Refresh-Path

Write-Log 'Configurando variaveis de ambiente Java...'

$correttoBase = 'C:\Program Files\Amazon Corretto'
if (Test-Path $correttoBase) {
    $jdkPath = Find-InstallDir -BasePath $correttoBase -Pattern 'jdk21*'
    if ($jdkPath) {
        Set-SystemEnvVar 'JAVA_HOME' $jdkPath
        Add-ToSystemPath "$jdkPath\bin"
        Write-Log "JAVA_HOME definido: $jdkPath" 'OK'
    } else {
        Write-Log 'Diretorio jdk21 nao encontrado em Corretto. Verifique a instalacao.' 'AVISO'
    }
} else {
    $javaCmd = Get-Command 'java' -ErrorAction SilentlyContinue
    if ($javaCmd) {
        $javaHome = Split-Path (Split-Path $javaCmd.Source -Parent) -Parent
        Set-SystemEnvVar 'JAVA_HOME' $javaHome
        Write-Log "JAVA_HOME definido via deteccao: $javaHome" 'OK'
    } else {
        Write-Log 'Java nao encontrado. Reinicie o terminal apos a instalacao.' 'AVISO'
    }
}

Write-Log 'Configurando variaveis de ambiente Maven...'
Refresh-Path
$mvnCmd = Get-Command 'mvn' -ErrorAction SilentlyContinue
if ($mvnCmd) {
    $mavenHome = Split-Path (Split-Path $mvnCmd.Source -Parent) -Parent
    Set-SystemEnvVar 'MAVEN_HOME' $mavenHome
    Set-SystemEnvVar 'M2_HOME' $mavenHome
} else {
    Write-Log 'mvn nao encontrado no PATH. Reinicie o terminal e verifique.' 'AVISO'
}

Write-Log 'Configurando variaveis de ambiente Gradle...'
$gradleCmd = Get-Command 'gradle' -ErrorAction SilentlyContinue
if ($gradleCmd) {
    $gradleHome = Split-Path (Split-Path $gradleCmd.Source -Parent) -Parent
    Set-SystemEnvVar 'GRADLE_HOME' $gradleHome
} else {
    Write-Log 'gradle nao encontrado no PATH. Reinicie o terminal e verifique.' 'AVISO'
}

Write-Section 'Validacao: Ambiente Java'
Test-Version 'java' -Arg '-version'
Test-Version 'mvn'
Test-Version 'gradle'

Write-Log '=== Ambiente Java concluido ===' 'OK'
