@echo off
setlocal
call "%~dp0lib\vars.bat"

set "MVN_VERSION=3.9.9"
set "MVN_ZIP=apache-maven-%MVN_VERSION%-bin.zip"
set "MVN_URL=https://dlcdn.apache.org/maven/maven-3/%MVN_VERSION%/binaries/%MVN_ZIP%"

echo.
echo === Maven %MVN_VERSION% (portable) ===
echo.

if exist "%AMBIENTE_MAVEN%\bin\mvn.cmd" (
    for /f "tokens=*" %%V in ('"%AMBIENTE_MAVEN%\bin\mvn.cmd" --version 2^>^&1 ^| findstr /i "maven"') do echo OK: %%V
    echo Maven ja instalado em %AMBIENTE_MAVEN%
    goto :configurar
)

if not exist "%AMBIENTE_MAVEN%" md "%AMBIENTE_MAVEN%"

echo Baixando Maven %MVN_VERSION%...
curl -L --progress-bar -o "%AMBIENTE_DL%\%MVN_ZIP%" "%MVN_URL%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao baixar Maven.
    goto :fim
)

echo Extraindo...
tar -xf "%AMBIENTE_DL%\%MVN_ZIP%" -C "%AMBIENTE%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao extrair Maven.
    goto :fim
)

:: Renomear apache-maven-x.x.x para maven
for /d %%D in ("%AMBIENTE%\apache-maven-%MVN_VERSION%") do (
    if exist "%%D\bin\mvn.cmd" (
        if exist "%AMBIENTE_MAVEN%" rmdir /s /q "%AMBIENTE_MAVEN%"
        ren "%%D" "maven"
    )
)
if not exist "%AMBIENTE_MAVEN%\bin\mvn.cmd" (
    echo ERRO: estrutura do Maven nao encontrada apos extracao.
    goto :fim
)
echo OK: Maven extraido em %AMBIENTE_MAVEN%

:configurar
setx MAVEN_HOME "%AMBIENTE_MAVEN%" >nul 2>&1
setx M2_HOME    "%AMBIENTE_MAVEN%" >nul 2>&1
set "MAVEN_HOME=%AMBIENTE_MAVEN%"
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_MAVEN%\bin"

echo.
if exist "%AMBIENTE_JAVA%\bin\java.exe" (
    set "JAVA_HOME=%AMBIENTE_JAVA%"
    for /f "tokens=*" %%V in ('"%AMBIENTE_MAVEN%\bin\mvn.cmd" --version 2^>^&1') do echo OK: %%V
) else (
    echo AVISO: JAVA_HOME nao configurado. Execute 02-java.bat primeiro.
    echo Maven instalado, mas requer Java para funcionar.
)
echo.
echo === Maven concluido ===
echo IMPORTANTE: abra um novo prompt para que mvn seja reconhecido.

:fim
endlocal
