@echo off
setlocal
call "%~dp0lib\vars.bat"

set "NODE_VERSION=22.15.0"
set "NODE_ZIP=node-v%NODE_VERSION%-win-x64.zip"
set "NODE_URL=https://nodejs.org/dist/v%NODE_VERSION%/%NODE_ZIP%"

echo.
echo === Node.js %NODE_VERSION% LTS (portable) ===
echo.

if exist "%AMBIENTE_NODE%\node.exe" (
    for /f "tokens=*" %%V in ('"%AMBIENTE_NODE%\node.exe" --version 2^>^&1') do echo OK: node %%V
    echo Node.js ja instalado em %AMBIENTE_NODE%
    goto :configurar
)

echo Baixando Node.js %NODE_VERSION%...
curl -L --progress-bar -o "%AMBIENTE_DL%\%NODE_ZIP%" "%NODE_URL%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao baixar Node.js.
    goto :fim
)

echo Extraindo...
tar -xf "%AMBIENTE_DL%\%NODE_ZIP%" -C "%AMBIENTE%"
if %errorlevel% neq 0 (
    echo ERRO: falha ao extrair Node.js.
    goto :fim
)

:: Renomear a pasta extraida para nodejs
for /d %%D in ("%AMBIENTE%\node-v%NODE_VERSION%-win-x64") do (
    if exist "%%D\node.exe" (
        if exist "%AMBIENTE_NODE%" rmdir /s /q "%AMBIENTE_NODE%"
        ren "%%D" "nodejs"
    )
)
if not exist "%AMBIENTE_NODE%\node.exe" (
    echo ERRO: estrutura do Node.js nao encontrada apos extracao.
    goto :fim
)
echo OK: Node.js extraido em %AMBIENTE_NODE%

:configurar
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_NODE%"
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_NODE%\node_modules\npm\bin"

echo.
for /f "tokens=*" %%V in ('"%AMBIENTE_NODE%\node.exe" --version 2^>^&1') do echo OK: node %%V
for /f "tokens=*" %%V in ('"%AMBIENTE_NODE%\npm.cmd" --version 2^>^&1') do echo OK: npm %%V
echo.
echo === Node.js concluido ===
echo IMPORTANTE: abra um novo prompt para que node e npm sejam reconhecidos.

:fim
endlocal
