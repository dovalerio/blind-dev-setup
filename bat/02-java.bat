@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vars.bat"

echo.
echo === Java JDK — OpenJDK portable ===
echo.
echo  1 - JDK 11 LTS  (~180 MB)
echo  2 - JDK 17 LTS  (~180 MB)
echo  3 - JDK 21 LTS  (~190 MB)
echo  4 - JDK 25 LTS  (~200 MB)
echo  S - Pular
echo.
set /p "ESCOLHA=Versao: "

if /i "!ESCOLHA!"=="S" goto :fim
if "!ESCOLHA!"=="1" set "JVER=11"
if "!ESCOLHA!"=="2" set "JVER=17"
if "!ESCOLHA!"=="3" set "JVER=21"
if "!ESCOLHA!"=="4" set "JVER=25"

if "!JVER!"=="" (
    echo Opcao invalida.
    goto :fim
)

set "JDEST=!AMBIENTE!\java!JVER!"
set "JDL=!AMBIENTE_DL!\jdk!JVER!.zip"
set "JURL="
if "!JVER!"=="11" set "JURL=https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip"
if "!JVER!"=="17" set "JURL=https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip"
if "!JVER!"=="21" set "JURL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_windows-x64_bin.zip"
if "!JVER!"=="25" set "JURL=https://api.adoptium.net/v3/binary/latest/25/ga/windows/x64/jdk/hotspot/normal/eclipse"
if "!JURL!"=="" ( echo ERRO: URL nao configurada para JDK !JVER!. & goto :fim )

echo.
if exist "!JDEST!\bin\java.exe" (
    echo OK: JDK !JVER! ja instalado em !JDEST!
    goto :configurar
)

echo Baixando OpenJDK !JVER! (~180-200 MB)...
curl -L --progress-bar -o "!JDL!" "!JURL!"
if !errorlevel! neq 0 (
    echo ERRO: falha no download do JDK !JVER!.
    goto :fim
)

echo Extraindo...
tar -xf "!JDL!" -C "!AMBIENTE!"
if !errorlevel! neq 0 (
    echo ERRO: falha na extracao.
    goto :fim
)

for /d %%D in ("!AMBIENTE!\jdk-!JVER!*") do (
    if exist "%%D\bin\java.exe" (
        if exist "!JDEST!" rmdir /s /q "!JDEST!"
        ren "%%D" "java!JVER!"
    )
)
if not exist "!JDEST!\bin\java.exe" (
    echo ERRO: estrutura do JDK nao encontrada apos extracao.
    goto :fim
)
echo OK: JDK !JVER! extraido em !JDEST!

:configurar
setx JAVA_HOME "!JDEST!" >nul 2>&1
set "JAVA_HOME=!JDEST!"
call "%~dp0lib\path_usuario.bat" "!JDEST!\bin"

echo.
for /f "tokens=*" %%V in ('"!JDEST!\bin\java.exe" -version 2^>^&1') do echo OK: %%V
echo JAVA_HOME=!JAVA_HOME!
echo.
echo === Java !JVER! concluido ===
echo IMPORTANTE: abra um novo prompt para que JAVA_HOME seja reconhecido.

:fim
endlocal
