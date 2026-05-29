@echo off
setlocal
call "%~dp0lib\vars.bat"

echo.
echo === Ferramentas base ===
echo.

:: --- curl ---
echo [curl]
where curl >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%V in ('curl --version 2^>^&1 ^| findstr /i "curl"') do echo OK: %%V
) else (
    echo AVISO: curl nao encontrado no PATH.
    echo   Windows 10 1803+ inclui curl em %SystemRoot%\System32\curl.exe
    echo   Verifique se %SystemRoot%\System32 esta no PATH.
)

:: --- jq ---
echo.
echo [jq]
if exist "%AMBIENTE_BIN%\jq.exe" (
    for /f "tokens=*" %%V in ('"%AMBIENTE_BIN%\jq.exe" --version 2^>^&1') do echo OK: jq %%V
    goto :jq_ok
)
echo Baixando jq...
curl -L --progress-bar -o "%AMBIENTE_BIN%\jq.exe" ^
  "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe"
if %errorlevel% neq 0 ( echo ERRO: falha ao baixar jq. & goto :jq_ok )
echo OK: jq instalado em %AMBIENTE_BIN%\jq.exe
call "%~dp0lib\path_usuario.bat" "%AMBIENTE_BIN%"
:jq_ok

:: --- git ---
echo.
echo [git]
where git >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%V in ('git --version 2^>^&1') do echo OK: %%V
) else (
    echo AVISO: git nao encontrado.
    echo   Para instalar sem admin: winget install --id Git.Git --scope user --silent
    echo   Ou baixe o instalador de usuario em: https://git-scm.com/download/win
)

echo.
echo === Ferramentas base concluidas ===
endlocal
