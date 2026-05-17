# blind-dev-setup

Configuracao automatizada de workstation para desenvolvedores cegos ou com baixa visao no Windows 11.

Todos os scripts rodam no PowerShell 7 via terminal. Sem interfaces graficas, sem dependencia de mouse. Mensagens lineares e compativeis com NVDA.

---

## Pre-requisitos

- Windows 11 atualizado
- winget (App Installer, ja incluso no Windows 11)
- PowerShell 7: `winget install Microsoft.PowerShell`
- Execucao como Administrador

---

## Inicio rapido

Abra o PowerShell 7 como Administrador e execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd C:\caminho\para\blind-dev-setup
.\bootstrap.ps1
```

O script verifica admin, winget, PS7 e conectividade antes de exibir o menu.

---

## Menu principal

```
=================================
 Blind Dev Setup
=================================

 1 - Configuracao base
 2 - Ferramentas de IA
 3 - Ambiente Java
 4 - Ambiente Python
 5 - Ambiente Node.js
 6 - Ambiente PHP
 7 - Cloud e DevOps
 8 - IDEs
 9 - Bancos de dados
10 - Acessibilidade
11 - Instalar tudo
 E - Exportar configuracao atual
 0 - Sair
```

---

## Selecao de versoes

Softwares com multiplas versoes exibem um submenu numerado. Exemplo ao selecionar a opcao 3 (Java):

```
=================================
 Escolha a versao do JDK
=================================

0 - Amazon Corretto 21 LTS
1 - Amazon Corretto 25
2 - Eclipse Temurin 21 LTS
3 - Eclipse Temurin 17 LTS
4 - Microsoft OpenJDK 21
5 - Oracle JDK 21

Digite a opcao:
```

O mesmo fluxo se aplica a Python, Node.js, PHP, banco de dados, IDEs e ferramentas de build.

---

## Ordem recomendada para maquina nova

1. Opcao 1 - Configuracao base (instala git, chocolatey e ferramentas CLI essenciais)
2. Opcao 4 - Python (necessario para ferramentas de IA via pipx)
3. Opcao 5 - Node.js (necessario para ferramentas de IA via npm)
4. Opcao 2 - Ferramentas de IA
5. Demais opcoes conforme necessidade
6. Opcao 10 - Acessibilidade (instala dicionarios NVDA automaticamente)

Ou use a opcao 11 para instalar tudo em sequencia.

---

## Estrutura do repositorio

```
blind-dev-setup/
  bootstrap.ps1              Ponto de entrada. Pre-checks e menu principal.
  helpers/
    common.ps1               Todas as funcoes reutilizaveis.
  scripts/
    01-base.ps1              Configuracao base.
    02-ai-tools.ps1          Ferramentas de IA.
    03-java.ps1              Ambiente Java com selecao de JDK e build tool.
    04-python.ps1            Ambiente Python com selecao de versao.
    05-node.ps1              Ambiente Node.js com selecao de versao.
    06-php.ps1               Ambiente PHP com selecao de versao.
    07-cloud.ps1             Cloud e DevOps.
    08-ides.ps1              IDEs com selecao de edicao.
    09-databases.ps1         Bancos de dados com selecao de versao.
    10-accessibility.ps1     Acessibilidade e dicionarios NVDA.
  configs/
    base.json                Pacotes da configuracao base.
    ai.json                  Ferramentas de IA.
    java.json                Versoes de JDK e build tools.
    python.json              Versoes de Python e ferramentas.
    node.json                Versoes de Node.js e ferramentas.
    php.json                 Versoes de PHP e ferramentas.
    cloud.json               Ferramentas de cloud e DevOps.
    ides.json                IDEs e edicoes disponiveis.
    databases.json           Versoes de bancos de dados.
    accessibility.json       Ferramentas de acessibilidade.
  nvda/
    dicts/
      default.dic            Dicionario global NVDA (todos os apps).
      WindowsTerminal.dic    Terminal, Claude Code e git.
      idea64.dic             IntelliJ IDEA (em desenvolvimento).
      pycharm64.dic          PyCharm (em desenvolvimento).
      code.dic               VS Code (em desenvolvimento).
      chrome.dic             Chrome (em desenvolvimento).
  logs/
    setup-YYYY-MM-DD.log     Log gerado automaticamente.
  exports/
    winget-export-DATA.json  Lista de pacotes exportada pelo winget.
    environment-DATA.txt     Snapshot de variaveis de ambiente.
```

---

## Referencia: helpers/common.ps1

Funcoes disponiveis em todos os scripts via dot-source:

- `Write-AccessibleMessage`: exibe mensagem com prefixo falado (INFO, OK, AVISO, ERRO) e grava no log
- `Write-SetupLog`: grava linha no arquivo de log com timestamp
- `Ensure-Admin`: encerra com erro se nao for administrador
- `Test-Connectivity`: verifica conexao com a internet antes de prosseguir
- `Test-CommandExists`: verifica se um comando esta disponivel no PATH
- `Test-WingetInstalled`: verifica se um pacote esta instalado no winget
- `Test-Version`: executa o comando com --version e exibe o resultado
- `Select-VersionMenu`: exibe lista numerada e retorna o item selecionado
- `Install-WingetPackage`: instala via winget com verificacao de idempotencia
- `Install-ChocoPackage`: instala via chocolatey com verificacao de idempotencia
- `Install-NpmPackage`: instala pacote npm global
- `Install-PipxPackage`: instala via pipx
- `Invoke-WithRetry`: executa um bloco com tentativas automaticas em caso de falha
- `Add-ToSystemPath`: adiciona caminho ao PATH do sistema permanentemente
- `Set-SystemEnvVar`: define variavel de ambiente no sistema e na sessao atual
- `Refresh-EnvironmentVariables`: atualiza o PATH da sessao apos instalacoes
- `Read-Config`: le e converte um arquivo JSON de configs/
- `Invoke-Export`: exporta lista winget e snapshot de variaveis para exports/

---

## Referencia: scripts

### 01-base.ps1

Instala Chocolatey e atualiza fontes do winget. Em seguida instala todos os pacotes definidos em `configs/base.json`:

git, GitHub CLI, Windows Terminal, PowerShell 7, 7-Zip, curl, wget, jq, yq, ripgrep, fd, fzf, Oh My Posh, VS Code, Notepad++.

### 02-ai-tools.ps1

Requer Node.js e pipx instalados. Instala automaticamente se nao encontrar.

Claude Code, Gemini CLI e Codex CLI via npm. Aider e OpenAI CLI via pipx. GitHub Copilot via extensao gh. Ollama opcional (prompt interativo).

### 03-java.ps1

Exibe menu de selecao de JDK: Corretto 21, Corretto 25, Temurin 21, Temurin 17, MS OpenJDK 21, Oracle JDK 21.

Exibe menu de selecao de build tool: Maven ou Gradle.

Configura automaticamente JAVA_HOME, MAVEN_HOME, M2_HOME e GRADLE_HOME.

### 04-python.ps1

Exibe menu de selecao: Python 3.13, 3.12 ou 3.11.

Instala pipx apos o Python. Instala via pipx ou pip: uv, Poetry, Ruff, Black, virtualenv.

### 05-node.ps1

Exibe menu de selecao: Node.js LTS ou Current.

Instala via npm: pnpm, yarn. Via winget: bun, deno.

### 06-php.ps1

Exibe menu de selecao: PHP 8.4, 8.3 ou 8.2.

Instala Composer via script oficial. Instala Symfony CLI via winget.

### 07-cloud.ps1

Instala automaticamente: kubectl, Helm, Terraform, AWS CLI, Azure CLI, Google Cloud SDK.

Opcional com prompt: Docker Desktop, k9s, Lens.

### 08-ides.ps1

Exibe menus de selecao de edicao para IntelliJ IDEA (Community ou Ultimate), PyCharm (Community ou Professional) e VS Code (Stable ou Insiders).

Prompt opcional para Rider e Android Studio.

### 09-databases.ps1

Exibe menu de selecao para PostgreSQL (17, 16, 15) e MySQL (8.4 LTS ou 8.0).

Opcional com prompt: MongoDB, Redis via Docker, Redis via Memurai.

Instala automaticamente DBeaver Community e TablePlus.

### 10-accessibility.ps1

Prompt para NVDA e Accessibility Insights. Instala PowerToys automaticamente.

Copia todos os dicionarios NVDA de `nvda/dicts/` para o perfil do usuario em `%APPDATA%\nvda\speechDicts\`.

---

## Referencia: configs JSON

Cada arquivo JSON e a fonte de verdade para IDs de pacotes do script correspondente. Para adicionar ou atualizar um pacote, edite o JSON sem precisar alterar o script.

Estrutura padrao de entrada:

```json
{
  "name": "Nome do pacote",
  "wingetId": "Publisher.PackageName",
  "chocoId": "package-name",
  "testCommand": "comando"
}
```

Para entradas com versoes multiplas (java, python, node, php, databases), o array e passado diretamente para `Select-VersionMenu`.

---

## Exportar configuracao

No menu principal, pressione `E` para exportar:

- `exports/winget-export-DATA.json`: lista de todos os pacotes instalados via winget, importavel em outra maquina com `winget import`
- `exports/environment-DATA.txt`: snapshot das variaveis JAVA_HOME, MAVEN_HOME, GRADLE_HOME e PATH

Para replicar o setup em outra maquina:

```powershell
winget import -i exports\winget-export-DATA.json --accept-package-agreements
```

---

## Logs

Cada execucao grava em `logs\setup-YYYY-MM-DD.log` com timestamp e nivel por linha.

Acompanhar em tempo real:

```powershell
Get-Content logs\setup-2026-05-17.log -Wait
```

Niveis registrados: INFO, OK, AVISO, ERRO.

---

## Checklist de validacao pos-instalacao

```powershell
git --version
gh --version
choco --version
pwsh --version
rg --version
fd --version
fzf --version
jq --version
yq --version
code --version
python --version
pip --version
pipx --version
uv --version
poetry --version
ruff --version
node --version
npm --version
pnpm --version
bun --version
deno --version
java -version
mvn --version
gradle --version
php -v
composer --version
symfony version
claude --version
gemini --version
codex --version
aider --version
kubectl version --client
helm version
terraform version
aws --version
az --version
gcloud --version
docker --version
psql --version
mysql --version
```

---

## Solucao de problemas

**Comando nao encontrado apos instalacao:** feche e reabra o terminal. O script atualiza o PATH do sistema mas a sessao atual pode nao refletir a mudanca.

**winget retorna erro de fonte:** execute `winget source reset --force` e depois `winget source update`.

**Erro de politica de execucao:** execute `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.

**JAVA_HOME nao definido:** reabra o terminal apos instalar o JDK e execute `.\scripts\03-java.ps1` diretamente.

**Chocolatey nao encontrado:** execute `.\scripts\01-base.ps1` diretamente como administrador.

---

## Dicionarios NVDA

Os dicionarios estao em `nvda\dicts\`. O script `10-accessibility.ps1` os copia automaticamente.

Para instalacao manual:

```powershell
Copy-Item nvda\dicts\default.dic "$env:APPDATA\nvda\speechDicts\default.dic"
Copy-Item nvda\dicts\WindowsTerminal.dic "$env:APPDATA\nvda\speechDicts\appDicts\WindowsTerminal.dic"
```

Apos copiar, recarregue o NVDA: NVDA mais N, Ferramentas, Recarregar plugins.

**default.dic** (global, todos os apps): spinner braille, status com texto (concluido, erro, aviso), emojis decorativos, arvore de arquivos com anuncio de inicio e fim, botoes de radio marcado e desmarcado, seletor de menu.

**WindowsTerminal.dic** (terminal): bordas de UI, saida do git (diff, status, push, pull), hashes SHA1, Claude Code tokens, codigos de escape ANSI.

**Formato dos arquivos .dic:** TSV com quatro campos separados por TAB: padrao, substituicao, sensivel-a-maiusculas (0 ou 1) e tipo (0 simples, 1 regex, 2 palavra-inteira). Substituicao vazia silencia o padrao.
