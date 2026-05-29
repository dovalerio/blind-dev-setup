@echo off
:: Baixa todas as ferramentas para a pasta zip\ do repositorio.
:: Execute este script UMA VEZ em um computador com internet
:: para popular o repositorio. Depois copie ou commite o repositorio
:: com os ZIPs para usar em maquinas sem internet.

setlocal
set "ZIP=%~dp0..\zip"

echo.
echo ===================================================
echo  Baixando ferramentas para zip\  (requer internet)
echo ===================================================
echo.

:: Verificar curl
where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: curl nao encontrado. Verifique o PATH.
    goto :fim
)

:: ---------------------------------------------------------
:: Java — OpenJDK (11, 17, 21, 25)  ~180-200 MB cada
:: ---------------------------------------------------------
echo [1/6] Java OpenJDK 11, 17, 21 e 25
call :baixar_jdk 11
call :baixar_jdk 17
call :baixar_jdk 21
call :baixar_jdk 25

:: ---------------------------------------------------------
:: Node.js 22 LTS portable
:: ---------------------------------------------------------
echo.
echo [2/6] Node.js 22 LTS  ~20 MB
if exist "%ZIP%\nodejs\node22-win-x64.zip" (
    echo OK: ja existe. Pulando.
) else (
    curl -L --progress-bar ^
         -o "%ZIP%\nodejs\node22-win-x64.zip" ^
         "https://nodejs.org/dist/v22.15.0/node-v22.15.0-win-x64.zip"
    if %errorlevel% neq 0 ( echo ERRO: falha no download do Node.js. )
)

:: ---------------------------------------------------------
:: Go 1.24
:: ---------------------------------------------------------
echo.
echo [3/6] Go 1.24  ~65 MB
if exist "%ZIP%\go\go124-win-x64.zip" (
    echo OK: ja existe. Pulando.
) else (
    curl -L --progress-bar ^
         -o "%ZIP%\go\go124-win-x64.zip" ^
         "https://go.dev/dl/go1.24.3.windows-amd64.zip"
    if %errorlevel% neq 0 ( echo ERRO: falha no download do Go. )
)

:: ---------------------------------------------------------
:: Maven 3.9
:: ---------------------------------------------------------
echo.
echo [4/6] Maven 3.9  ~10 MB
if exist "%ZIP%\maven\maven39-bin.zip" (
    echo OK: ja existe. Pulando.
) else (
    curl -L --progress-bar ^
         -o "%ZIP%\maven\maven39-bin.zip" ^
         "https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip"
    if %errorlevel% neq 0 ( echo ERRO: falha no download do Maven. )
)

:: ---------------------------------------------------------
:: Python 3.13 embeddable
:: ---------------------------------------------------------
echo.
echo [5/6] Python 3.13 embeddable  ~12 MB
if exist "%ZIP%\python\python313-embed-x64.zip" (
    echo OK: ja existe. Pulando.
) else (
    curl -L --progress-bar ^
         -o "%ZIP%\python\python313-embed-x64.zip" ^
         "https://www.python.org/ftp/python/3.13.3/python-3.13.3-embed-amd64.zip"
    if %errorlevel% neq 0 ( echo ERRO: falha no download do Python. )
)

:: ---------------------------------------------------------
:: jq (executavel unico)
:: ---------------------------------------------------------
echo.
echo [6/6] jq 1.7.1  ~1 MB
if exist "%ZIP%\tools\jq.exe" (
    echo OK: ja existe. Pulando.
) else (
    curl -L --progress-bar ^
         -o "%ZIP%\tools\jq.exe" ^
         "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe"
    if %errorlevel% neq 0 ( echo ERRO: falha no download do jq. )
)

:: ---------------------------------------------------------
:: Resumo
:: ---------------------------------------------------------
echo.
echo ===================================================
echo  Resultado:
echo ===================================================
call :verificar "%ZIP%\java\jdk11-win-x64.zip"        "Java JDK 11"
call :verificar "%ZIP%\java\jdk17-win-x64.zip"        "Java JDK 17"
call :verificar "%ZIP%\java\jdk21-win-x64.zip"        "Java JDK 21"
call :verificar "%ZIP%\java\jdk25-win-x64.zip"        "Java JDK 25"
call :verificar "%ZIP%\nodejs\node22-win-x64.zip"     "Node.js 22"
call :verificar "%ZIP%\go\go124-win-x64.zip"          "Go 1.24"
call :verificar "%ZIP%\maven\maven39-bin.zip"         "Maven 3.9"
call :verificar "%ZIP%\python\python313-embed-x64.zip" "Python 3.13"
call :verificar "%ZIP%\tools\jq.exe"                  "jq"
echo.
echo Agora execute bat\instalar-offline.bat no computador de destino.
goto :fim

:baixar_jdk
:: %1 = versao (11, 17, 21, 25)
echo.
echo  JDK %~1:
if exist "%ZIP%\java\jdk%~1-win-x64.zip" (
    echo  OK: ja existe. Pulando.
    goto :eof
)
set "JURL="
if "%~1"=="11" set "JURL=https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip"
if "%~1"=="17" set "JURL=https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip"
if "%~1"=="21" set "JURL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_windows-x64_bin.zip"
if "%~1"=="25" set "JURL=https://api.adoptium.net/v3/binary/latest/25/ga/windows/x64/jdk/hotspot/normal/eclipse"
if "%JURL%"=="" ( echo  ERRO: versao %~1 nao suportada. & goto :eof )
curl -L --progress-bar ^
     -o "%ZIP%\java\jdk%~1-win-x64.zip" ^
     "%JURL%"
if %errorlevel% neq 0 ( echo  ERRO: falha no download do JDK %~1. )
goto :eof

:verificar
if exist "%~1" (
    for %%F in ("%~1") do echo OK : %~2  [%%~zF bytes]
) else (
    echo FALTA: %~2
)
goto :eof

:fim
endlocal
