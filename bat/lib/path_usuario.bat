@echo off
:: Adiciona %1 ao PATH permanente do usuario (sem admin) e na sessao atual.
:: Uso: call "%~dp0path_usuario.bat" "C:\caminho\a\adicionar"
powershell -NoProfile -Command ^
  "$c='%~1';" ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User');" ^
  "$itens=$p -split ';' | Where-Object { $_ -ne '' };" ^
  "if($itens -notcontains $c){[Environment]::SetEnvironmentVariable('Path',($itens+$c -join ';'),'User')}" ^
  2>nul
set "PATH=%PATH%;%~1"
