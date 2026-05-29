@echo off
:: Variaveis compartilhadas — inclua com: call "%~dp0lib\vars.bat"  (de bat\)
::                            ou:          call "%~dp0..\bat\lib\vars.bat"

set "AMBIENTE=%USERPROFILE%\ambiente"
set "AMBIENTE_BIN=%AMBIENTE%\bin"
set "AMBIENTE_DL=%AMBIENTE%\downloads"
set "AMBIENTE_JAVA=%AMBIENTE%\java"
set "AMBIENTE_NODE=%AMBIENTE%\nodejs"
set "AMBIENTE_GO=%AMBIENTE%\go"
set "AMBIENTE_MAVEN=%AMBIENTE%\maven"
set "AMBIENTE_PYTHON=%AMBIENTE%\python"

if not exist "%AMBIENTE_BIN%"  md "%AMBIENTE_BIN%"
if not exist "%AMBIENTE_DL%"   md "%AMBIENTE_DL%"
