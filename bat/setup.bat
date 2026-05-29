@echo off
setlocal enabledelayedexpansion
call "%~dp0lib\vars.bat"

:menu
cls
echo.
echo  ===================================================
echo   Blind Dev Setup  ^|  Sem admin  ^|  %AMBIENTE%
echo  ===================================================
echo.
echo   --- Online (requer internet) ---
echo   1 - Ferramentas base   (curl, jq, git)
echo   2 - Java JDK 21        (Temurin portable)
echo   3 - Node.js 22 LTS     (portable)
echo   4 - Go 1.24            (portable)
echo   5 - Maven 3.9          (portable)
echo   6 - Testar curl        (GET, POST, download)
echo.
echo   --- Offline (usa ZIPs em zip\) ---
echo   7 - Baixar ZIPs para uso offline
echo   8 - Instalar a partir dos ZIPs (sem internet)
echo.
echo   0 - Sair
echo.
set /p "opcao=Digite uma opcao: "

if "%opcao%"=="1" call "%~dp001-ferramentas.bat" & goto :pausa
if "%opcao%"=="2" call "%~dp002-java.bat"        & goto :pausa
if "%opcao%"=="3" call "%~dp003-node.bat"        & goto :pausa
if "%opcao%"=="4" call "%~dp004-go.bat"          & goto :pausa
if "%opcao%"=="5" call "%~dp005-maven.bat"       & goto :pausa
if "%opcao%"=="6" call "%~dp0testar-curl.bat"        & goto :pausa
if "%opcao%"=="7" call "%~dp0baixar-zips.bat"       & goto :pausa
if "%opcao%"=="8" call "%~dp0instalar-offline.bat"  & goto :pausa
if "%opcao%"=="0" goto :fim
echo Opcao invalida.
:pausa
echo.
pause
goto :menu

:fim
endlocal
