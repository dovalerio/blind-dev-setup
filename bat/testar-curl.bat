@echo off
setlocal
call "%~dp0lib\vars.bat"

echo.
echo ===================================================
echo  Testes de curl no prompt do Windows
echo ===================================================
echo.

:: ---------------------------------------------------------
:: 0. Verificar versao do curl
:: ---------------------------------------------------------
echo [0] Versao do curl
echo.
curl --version
if %errorlevel% neq 0 (
    echo ERRO: curl nao encontrado. Verifique o PATH.
    goto :fim
)

echo.
echo ---------------------------------------------------------
echo Pressione Enter para continuar para o teste GET...
pause >nul

:: ---------------------------------------------------------
:: 1. GET simples — retorna IP publico
:: ---------------------------------------------------------
echo.
echo [1] GET simples — IP publico
echo     curl https://api.ipify.org
echo.
curl -s https://api.ipify.org
echo.

echo.
echo ---------------------------------------------------------
echo Pressione Enter para continuar para GET com JSON...
pause >nul

:: ---------------------------------------------------------
:: 2. GET com resposta JSON (httpbun)
:: ---------------------------------------------------------
echo.
echo [2] GET com headers e resposta JSON
echo     curl -s https://httpbun.com/get
echo.
curl -s https://httpbun.com/get

echo.
echo ---------------------------------------------------------
echo Pressione Enter para continuar para POST com JSON...
pause >nul

:: ---------------------------------------------------------
:: 3. POST com corpo JSON
:: ---------------------------------------------------------
echo.
echo [3] POST com Content-Type: application/json
echo     curl -s -X POST -H "Content-Type: application/json" -d "{...}" https://httpbun.com/post
echo.
curl -s -X POST ^
     -H "Content-Type: application/json" ^
     -H "Accept: application/json" ^
     -d "{\"nome\": \"danilo\", \"ferramenta\": \"blind-dev-setup\"}" ^
     https://httpbun.com/post

echo.
echo ---------------------------------------------------------
echo Pressione Enter para continuar para download de arquivo...
pause >nul

:: ---------------------------------------------------------
:: 4. Download de arquivo com barra de progresso
:: ---------------------------------------------------------
echo.
echo [4] Download de arquivo — jq para %AMBIENTE_BIN%
set "DESTINO=%AMBIENTE_DL%\jq-teste.exe"
echo     curl -L --progress-bar -o "%DESTINO%" https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe
echo.
curl -L --progress-bar ^
     -o "%DESTINO%" ^
     "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe"
if %errorlevel% equ 0 (
    echo.
    echo OK: arquivo salvo em %DESTINO%
    for %%F in ("%DESTINO%") do echo     Tamanho: %%~zF bytes
) else (
    echo ERRO: falha no download.
)

echo.
echo ---------------------------------------------------------
echo Pressione Enter para continuar para POST com autenticacao...
pause >nul

:: ---------------------------------------------------------
:: 5. GET com header de autenticacao (Bearer token — exemplo)
:: ---------------------------------------------------------
echo.
echo [5] GET com Authorization: Bearer (exemplo — token ficticio)
echo.
curl -s ^
     -H "Authorization: Bearer meu-token-aqui" ^
     -H "Accept: application/json" ^
     https://httpbun.com/bearer

echo.
echo.
echo ===================================================
echo  Referencia rapida de flags uteis do curl
echo ===================================================
echo.
echo  -s              silencioso (sem barra de progresso)
echo  -i              incluir cabecalhos HTTP na saida
echo  -L              seguir redirecionamentos (302, 301)
echo  --progress-bar  barra de progresso simples
echo  -o arquivo      salvar resposta em arquivo
echo  -O              salvar com nome original do servidor
echo  -X METODO       definir metodo: GET POST PUT DELETE PATCH
echo  -H "K: V"       adicionar cabecalho
echo  -d "corpo"      corpo da request (implica POST)
echo  -u user:senha   autenticacao Basic
echo  -k              ignorar verificacao SSL (apenas testes locais)
echo  --max-time 10   timeout em segundos
echo  -w "\n%%{http_code}\n"  mostrar codigo HTTP apos resposta
echo.
echo  Exemplo completo:
echo    curl -s -X POST -H "Content-Type: application/json" ^
echo         -H "Authorization: Bearer TOKEN" ^
echo         -d "{\"chave\":\"valor\"}" ^
echo         -w "\n\nHTTP: %%{http_code}\n" ^
echo         https://api.exemplo.com/endpoint
echo.

:fim
endlocal
