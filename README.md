# blind-dev-setup

Configuracao automatizada de ambiente de desenvolvimento para desenvolvedores cegos ou com baixa visao no Windows 11.

Todos os scripts rodam no terminal (PowerShell 7), sem interfaces graficas, com mensagens lineares e acessiveis ao NVDA.

---

## Pre-requisitos

- Windows 11
- PowerShell 7 (`winget install Microsoft.PowerShell`)
- winget (App Installer - incluso no Windows 11 atualizado)
- Execucao como Administrador

---

## Como executar

Abra o PowerShell 7 como Administrador:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd C:\caminho\para\blind-dev-setup
.\bootstrap.ps1
```

O menu principal sera exibido. Digite o numero da opcao e pressione Enter.

---

## Menu principal

```
1 - Configuracao base       (gerenciadores de pacotes e ferramentas essenciais)
2 - Ferramentas de IA       (Claude Code, Copilot, Gemini, Aider)
3 - Ambiente Java           (Corretto 21, Maven, Gradle, IntelliJ IDEA)
4 - Ambiente Python         (3.12, pip, pipx, poetry, ruff)
5 - Ambiente Node.js        (LTS, pnpm, yarn)
6 - Ambiente PHP            (PHP, Composer)
7 - Ferramentas de acessibilidade (NVDA, PowerToys)
8 - Utilitarios de desenvolvimento (Docker, DBeaver, jq, yq)
9 - Instalar tudo
0 - Sair
```

---

## Ordem recomendada de execucao

Para uma maquina nova:

1. Opcao 1 - Configuracao base
2. Opcao 4 - Ambiente Python (necessario para ferramentas de IA via pipx)
3. Opcao 5 - Ambiente Node.js (necessario para ferramentas de IA via npm)
4. Opcao 2 - Ferramentas de IA
5. Opcao 3 - Ambiente Java (se necessario)
6. Opcao 7 - Ferramentas de acessibilidade
7. Opcao 8 - Utilitarios de desenvolvimento

Ou use a Opcao 9 para instalar tudo de uma vez.

---

## Estrutura do repositorio

```
blind-dev-setup/
bootstrap.ps1                  Ponto de entrada. Menu principal.
configs/
  packages.json                IDs de todos os pacotes winget e chocolatey.
logs/
  setup-YYYY-MM-DD.log         Log gerado automaticamente em cada execucao.
nvda/
  dicts/
    default.dic                Dicionario global NVDA (todos os apps).
    WindowsTerminal.dic        Terminal, Claude Code e git.
    idea64.dic                 IntelliJ IDEA (em desenvolvimento).
    pycharm64.dic              PyCharm (em desenvolvimento).
    code.dic                   VS Code (em desenvolvimento).
    chrome.dic                 Chrome (em desenvolvimento).
scripts/
  00-common.ps1                Funcoes compartilhadas por todos os scripts.
  01-package-managers.ps1      Chocolatey, Git, GitHub CLI.
  02-core-tools.ps1            Terminal, PS7, 7zip, VSCode, Notepad++.
  03-ai-tools.ps1              Claude Code, Gemini, Copilot, Aider.
  10-java-env.ps1              Corretto 21, Maven, Gradle, IntelliJ.
  11-python-env.ps1            Python 3.12, pipx, poetry, ruff, black.
  12-node-env.ps1              Node.js LTS, pnpm, yarn.
  13-php-env.ps1               PHP, Composer.
  20-accessibility-tools.ps1   NVDA, PowerToys, Accessibility Insights.
  30-dev-utils.ps1             jq, yq, Postman, DBeaver, Docker.
```

---

## Referencia dos scripts

### 00-common.ps1

Funcoes disponiveis em todos os scripts:

- Write-Log: exibe mensagem no terminal e grava no log com timestamp e nivel INFO, OK, AVISO ou ERRO
- Assert-Administrator: encerra o script se nao for admin
- Test-CommandExists: verifica se um comando esta disponivel no PATH
- Install-Package: instala via winget com fallback para chocolatey
- Install-NpmGlobal: instala pacote npm global
- Install-PipxPackage: instala via pipx
- Add-ToSystemPath: adiciona caminho ao PATH do sistema permanentemente
- Set-SystemEnvVar: define variavel de ambiente no sistema
- Invoke-WithRetry: executa bloco com tentativas em caso de falha
- Test-Version: valida que o comando responde e exibe a versao
- Refresh-Path: atualiza o PATH da sessao atual apos instalacoes

### 01-package-managers.ps1

Chocolatey, Git e GitHub CLI. Base necessaria para todos os outros scripts.

### 02-core-tools.ps1

Windows Terminal, PowerShell 7, 7-Zip, wget, VS Code, Notepad++.

### 03-ai-tools.ps1

Claude Code e Gemini CLI via npm. GitHub Copilot via extensao gh. Aider e OpenAI CLI via pipx. Ollama opcional.

Requer Node.js (opcao 5) e Python/pipx (opcao 4) instalados primeiro.

### 10-java-env.ps1

Amazon Corretto 21, Apache Maven, Gradle e IntelliJ IDEA Community. Configura JAVA_HOME, MAVEN_HOME e GRADLE_HOME automaticamente.

### 11-python-env.ps1

Python 3.12, pipx, virtualenv, Poetry, Ruff e Black.

### 12-node-env.ps1

Node.js LTS, pnpm e yarn.

### 13-php-env.ps1

PHP e Composer.

### 20-accessibility-tools.ps1

NVDA (opcional), PowerToys e Accessibility Insights. Tambem copia os dicionarios NVDA do repositorio para o perfil do usuario automaticamente.

### 30-dev-utils.ps1

jq, yq, Postman, DBeaver e Docker Desktop opcional.

---

## Logs

Cada execucao gera um log em `logs\setup-YYYY-MM-DD.log`.

Para acompanhar em tempo real:

```powershell
Get-Content logs\setup-2026-05-16.log -Wait
```

---

## Checklist de validacao pos-instalacao

```powershell
git --version
gh --version
choco --version
pwsh --version
code --version
python --version
pip --version
pipx --version
poetry --version
node --version
npm --version
pnpm --version
java -version
mvn --version
gradle --version
php -v
composer --version
claude --version
gemini --version
aider --version
jq --version
yq --version
docker --version
```

---

## Solucao de problemas

Comando nao encontrado apos instalacao: feche e reabra o terminal. O PATH e atualizado pelo script mas o terminal atual pode nao refletir a mudanca.

winget retorna erro de fonte: execute `winget source reset --force` seguido de `winget source update`.

Erro de politica de execucao: execute `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.

JAVA_HOME nao definido: reabra o terminal apos instalar o Corretto e execute `10-java-env.ps1` novamente.

---

## Atualizar IDs de pacotes

Todos os IDs estao em `configs\packages.json`. Atualize o ID la e, se necessario, no script correspondente.

---

## Dicionarios NVDA

Os dicionarios estao em `nvda\dicts\`. O script `20-accessibility-tools.ps1` os copia automaticamente.

Para instalacao manual:

```powershell
Copy-Item nvda\dicts\default.dic "$env:APPDATA\nvda\speechDicts\default.dic"
Copy-Item nvda\dicts\WindowsTerminal.dic "$env:APPDATA\nvda\speechDicts\appDicts\WindowsTerminal.dic"
```

Apos copiar: NVDA + N, Ferramentas, Recarregar plugins.

### Dicionarios disponiveis

- default.dic: global, todos os apps. Spinner braille, status, emojis, arvore de arquivos, botoes de radio.
- WindowsTerminal.dic: terminal. Bordas de UI, saida git, Claude Code, codigos ANSI.
- idea64.dic: IntelliJ IDEA. Em desenvolvimento.
- pycharm64.dic: PyCharm. Em desenvolvimento.
- code.dic: VS Code. Em desenvolvimento.
- chrome.dic: Chrome. Em desenvolvimento.

### Formato dos arquivos .dic

Arquivos TSV com quatro campos separados por TAB:

```
padrao  substituicao  sensivel-maiusc  tipo
```

Tipos: 0 correspondencia simples, 1 expressao regular, 2 palavra inteira. Substituicao vazia silencia o padrao.
