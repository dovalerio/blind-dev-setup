@echo off
:: Instala as ferramentas a partir dos ZIPs em zip\
:: Sem internet, sem admin.
:: Requer: Windows 10 1803+ (tar e curl embutidos)

setlocal enabledelayedexpansion
call "%~dp0lib\vars.bat"
set "ZIP=%~dp0..\zip"

echo.
echo ===================================================
echo  Instalacao offline  ^|  destino: %AMBIENTE%
echo ===================================================
echo.

:: ---------------------------------------------------------
:: 1. Java JDK (escolha a versao)
:: ---------------------------------------------------------
echo [1/6] Java JDK
echo.
echo  ZIPs disponiveis em zip\java\:
set "V11=0" & set "V17=0" & set "V21=0" & set "V25=0"
if exist "%ZIP%\java\jdk11-win-x64.zip" ( set "V11=1" & echo   11 - JDK 11 LTS )
if exist "%ZIP%\java\jdk17-win-x64.zip" ( set "V17=1" & echo   17 - JDK 17 LTS )
if exist "%ZIP%\java\jdk21-win-x64.zip" ( set "V21=1" & echo   21 - JDK 21 LTS )
if exist "%ZIP%\java\jdk25-win-x64.zip" ( set "V25=1" & echo   25 - JDK 25 LTS )
echo    S - Pular
echo.

if "%V11%%V17%%V21%%V25%"=="0000" (
    echo FALTA: nenhum ZIP de Java em zip\java\
    goto :nodejs
)

set /p "JVER=Versao: "
if /i "%JVER%"=="S" goto :nodejs

set "JZIP="
if "%JVER%"=="11" if "%V11%"=="1" set "JZIP=%ZIP%\java\jdk11-win-x64.zip"
if "%JVER%"=="17" if "%V17%"=="1" set "JZIP=%ZIP%\java\jdk17-win-x64.zip"
if "%JVER%"=="21" if "%V21%"=="1" set "JZIP=%ZIP%\java\jdk21-win-x64.zip"
if "%JVER%"=="25" if "%V25%"=="1" set "JZIP=%ZIP%\java\jdk25-win-x64.zip"

if "%JZIP%"=="" (
    echo AVISO: versao invalida ou ZIP ausente. Pulando Java.
    goto :nodejs
)

set "JDEST=%AMBIENTE%\java%JVER%"

if exist "%JDEST%\bin\java.exe" (
    echo OK: JDK %JVER% ja instalado em %JDEST%
    goto :java_env
)
echo Extraindo JDK %JVER%...
tar -xf "%JZIP%" -C "%AMBIENTE%"
for /d %%D in ("%AMBIENTE%\jdk-%JVER%*") do (
    if exist "%%D\bin\java.exe" (
        if exist "%JDEST%" rmdir /s /q "%JDEST%"
        ren "%%D" "java%JVER%"
    )
)
if not exist "%JDEST%\bin\java.exe" (
    echo ERRO: falha ao extrair JDK %JVER%.
    goto :nodejs
)
echo OK: JDK %JVER% extraido em %JDEST%

:java_env
setx JAVA_HOME "%JDEST%" >nul 2>&1
set "JAVA_HOME=%JDEST%"
call "%~dp0lib\path_usuario.bat" "%JDEST%\bin"
for /f "tokens=*" %%V in ('"%JDEST%\bin\java.exe" -version 2^>^&1') do (
    echo     %%V & goto :nodejs
)

:: ---------------------------------------------------------
:: 2. Node.js 22
:: ---------------------------------------------------------
:nodejs
echo.
echo [2/6] Node.js 22 LTS
if exist "%AMBIENTE_NODE%\node.exe" (
    echo OK: ja instalado em %AMBIENTE_NODE%
    goto :nodejs_env
)
if not exist "%ZIP%\nodejs\node22-win-x64.zip" (
    echo FALTA: zip\nodejs\node22-win-x64.zip
    goto :golang
)
echo Extraindo...
tar -xf "%ZIP%\nodejs\node22-win-x64.zip" -C "%AMBIENTE%"
for /d %%D in ("%AMBIENTE%\node-v*-win-x64") do (
    if exist "%%D\node.exe" (
        if exist "%AMBIENTE_NODE%" rmdir /s /q "%AMBIENTE_NODE%"
        ren "%%D" "nodejs"
    )
)
if not exist "%AMBIENTE_NODE%\node.exe" (
    echo ERRO: falha ao extrair Node.js.
    goto :golang
)
echo OK: Node.js extraido.

:nodejs_env
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_NODE%"
for /f "tokens=*" %%V in ('"%AMBIENTE_NODE%\node.exe" --version 2^>^&1') do echo     node %%V

:: ---------------------------------------------------------
:: 3. Go 1.24
:: ---------------------------------------------------------
:golang
echo.
echo [3/6] Go 1.24
if exist "%AMBIENTE_GO%\bin\go.exe" (
    echo OK: ja instalado em %AMBIENTE_GO%
    goto :golang_env
)
if not exist "%ZIP%\go\go124-win-x64.zip" (
    echo FALTA: zip\go\go124-win-x64.zip
    goto :maven
)
echo Extraindo...
tar -xf "%ZIP%\go\go124-win-x64.zip" -C "%AMBIENTE%"
if not exist "%AMBIENTE_GO%\bin\go.exe" (
    echo ERRO: falha ao extrair Go.
    goto :maven
)
echo OK: Go extraido.

:golang_env
set "GOROOT=%AMBIENTE_GO%"
set "GOPATH=%USERPROFILE%\go"
if not exist "%GOPATH%\bin" md "%GOPATH%\bin"
setx GOROOT "%GOROOT%" >nul 2>&1
setx GOPATH "%GOPATH%" >nul 2>&1
call "%~dp0lib\path_usuario.bat" "%GOROOT%\bin"
call "%~dp0lib\path_usuario.bat" "%GOPATH%\bin"
for /f "tokens=*" %%V in ('"%AMBIENTE_GO%\bin\go.exe" version 2^>^&1') do echo     %%V

:: ---------------------------------------------------------
:: 4. Maven 3.9
:: ---------------------------------------------------------
:maven
echo.
echo [4/6] Maven 3.9
if exist "%AMBIENTE_MAVEN%\bin\mvn.cmd" (
    echo OK: ja instalado em %AMBIENTE_MAVEN%
    goto :maven_env
)
if not exist "%ZIP%\maven\maven39-bin.zip" (
    echo FALTA: zip\maven\maven39-bin.zip
    goto :python
)
echo Extraindo...
tar -xf "%ZIP%\maven\maven39-bin.zip" -C "%AMBIENTE%"
for /d %%D in ("%AMBIENTE%\apache-maven-*") do (
    if exist "%%D\bin\mvn.cmd" (
        if exist "%AMBIENTE_MAVEN%" rmdir /s /q "%AMBIENTE_MAVEN%"
        ren "%%D" "maven"
    )
)
if not exist "%AMBIENTE_MAVEN%\bin\mvn.cmd" (
    echo ERRO: falha ao extrair Maven.
    goto :python
)
echo OK: Maven extraido.

:maven_env
setx MAVEN_HOME "%AMBIENTE_MAVEN%" >nul 2>&1
setx M2_HOME    "%AMBIENTE_MAVEN%" >nul 2>&1
set "MAVEN_HOME=%AMBIENTE_MAVEN%"
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_MAVEN%\bin"
echo     mvn em %AMBIENTE_MAVEN%\bin

:: ---------------------------------------------------------
:: 5. Python 3.13 embeddable
:: ---------------------------------------------------------
:python
echo.
echo [5/6] Python 3.13
if exist "%AMBIENTE_PYTHON%\python.exe" (
    echo OK: ja instalado em %AMBIENTE_PYTHON%
    goto :python_env
)
if not exist "%ZIP%\python\python313-embed-x64.zip" (
    echo FALTA: zip\python\python313-embed-x64.zip
    goto :tools
)
echo Extraindo...
if not exist "%AMBIENTE_PYTHON%" md "%AMBIENTE_PYTHON%"
tar -xf "%ZIP%\python\python313-embed-x64.zip" -C "%AMBIENTE_PYTHON%"
if not exist "%AMBIENTE_PYTHON%\python.exe" (
    echo ERRO: falha ao extrair Python.
    goto :tools
)
echo OK: Python extraido.

:python_env
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_PYTHON%"
for /f "tokens=*" %%V in ('"%AMBIENTE_PYTHON%\python.exe" --version 2^>^&1') do echo     %%V
echo     AVISO: versao embeddable - pip nao incluido.

:: ---------------------------------------------------------
:: 6. jq
:: ---------------------------------------------------------
:tools
echo.
echo [6/6] jq
if exist "%AMBIENTE_BIN%\jq.exe" (
    echo OK: ja instalado em %AMBIENTE_BIN%\jq.exe
    goto :bin_path
)
if not exist "%ZIP%\tools\jq.exe" (
    echo FALTA: zip\tools\jq.exe
    goto :resumo
)
copy "%ZIP%\tools\jq.exe" "%AMBIENTE_BIN%\jq.exe" >nul
echo OK: jq copiado para %AMBIENTE_BIN%

:bin_path
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_BIN%"

:: ---------------------------------------------------------
:: Resumo
:: ---------------------------------------------------------
:resumo
echo.
echo ===================================================
echo  Instalacao concluida
echo ===================================================
echo  Ambiente: %AMBIENTE%
echo.
echo  IMPORTANTE: abra um NOVO prompt para que todas
echo  as variaveis de ambiente sejam reconhecidas.
echo ===================================================
echo.

endlocal
