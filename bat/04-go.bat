@echo off
setlocal
call "%~dp0lib\vars.bat"

set "GO_VERSION=1.24.3"
set "GO_ZIP=go%GO_VERSION%.windows-amd64.zip"
set "GO_URL=https://go.dev/dl/%GO_ZIP%"

echo.
echo === Go %GO_VERSION% (portable) ===
echo.

if exist "%AMBIENTE_GO%\bin\go.exe" (
    for /f "tokens=*" %%V in ('"%AMBIENTE_GO%\bin\go.exe" version 2^>^&1') do echo OK: %%V
    echo Go ja instalado em %AMBIENTE_GO%
    goto :configurar
)

echo Baixando Go %GO_VERSION%...
curl -L --progress-bar -o "%AMBIENTE_DL%\%GO_ZIP%" "%GO_URL%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao baixar Go.
    goto :fim
)

echo Extraindo...
tar -xf "%AMBIENTE_DL%\%GO_ZIP%" -C "%AMBIENTE%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao extrair Go.
    goto :fim
)

:: O zip do Go ja extrai para uma pasta chamada "go"
if not exist "%AMBIENTE_GO%\bin\go.exe" (
    echo ERRO: estrutura do Go nao encontrada apos extracao.
    goto :fim
)
echo OK: Go extraido em %AMBIENTE_GO%

:configurar
set "GOROOT=%AMBIENTE_GO%"
set "GOPATH=%USERPROFILE%\go"
if not exist "%GOPATH%\bin" md "%GOPATH%\bin"

setx GOROOT "%GOROOT%" >nul 2>&1
setx GOPATH "%GOPATH%" >nul 2>&1

call "%~dp0lib\path_usuario.bat" "%GOROOT%\bin"
call "%~dp0lib\path_usuario.bat" "%GOPATH%\bin"

echo.
for /f "tokens=*" %%V in ('"%AMBIENTE_GO%\bin\go.exe" version 2^>^&1') do echo OK: %%V
echo GOROOT=%GOROOT%
echo GOPATH=%GOPATH%
echo.
echo === Go concluido ===
echo IMPORTANTE: abra um novo prompt para que go seja reconhecido.

:fim
endlocal
