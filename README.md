# blind-dev-config

Configurações de acessibilidade para desenvolvedores cegos ou com baixa visão no Windows.

Este repositório centraliza arquivos de dicionário do NVDA e scripts de configuração para os aplicativos do dia a dia de desenvolvimento.

---

## Estrutura

```
blind-dev-config/
├── nvda/
│   └── dicts/          # Dicionários de fala por aplicativo
└── scripts/            # Scripts de instalação e configuração
```

---

## Dicionários NVDA (`nvda/dicts/`)

Os dicionários de fala do NVDA reduzem o ruído de caracteres especiais, bordas de UI e saídas de terminal, substituindo por texto significativo ou silenciando o que não agrega informação.

### Como instalar

Copie cada arquivo `.dic` para a pasta correspondente no NVDA:

| Tipo de dicionário | Caminho no Windows |
|---|---|
| Padrão (todos os apps) | `%APPDATA%\nvda\speechDicts\default.dic` |
| Por aplicativo | `%APPDATA%\nvda\speechDicts\appDicts\<arquivo>.dic` |

Após copiar, recarregue o NVDA: **NVDA + N → Ferramentas → Recarregar plugins**

---

### Arquivos disponíveis

| Arquivo | Aplicativo | Processo | Status |
|---|---|---|---|
| `default.dic` | Todos os aplicativos | — | ✓ Ativo |
| `WindowsTerminal.dic` | Windows Terminal | `WindowsTerminal.exe` | ✓ Ativo |
| `idea64.dic` | IntelliJ IDEA | `idea64.exe` | Em desenvolvimento |
| `pycharm64.dic` | PyCharm | `pycharm64.exe` | Em desenvolvimento |
| `code.dic` | Visual Studio Code | `code.exe` | Em desenvolvimento |
| `chrome.dic` | Google Chrome | `chrome.exe` | Em desenvolvimento |

---

### O que cada dicionário cobre

#### `default.dic` — global
- Spinner braille (animação de carregamento)
- Símbolos de status: `✓` → "Concluído", `✗` → "Erro", `⚠` → "aviso"
- Emojis decorativos de ferramentas e notificações
- Botões de rádio: `●` → "marcado", `○` → "desmarcado"
- Seletor de menu: `❯` → "selecionado"
- Navegação em árvore de arquivos: `├──` → "item", `└──` → "fim da árvore"
- Reticências e pontos decorativos

#### `WindowsTerminal.dic` — terminal
Tudo do `default.dic`, mais:
- Bordas de caixa da UI (`╭─────╮`, `│`, `└────╯`)
- Saída do **git**: `diff --git`, `@@ trecho @@`, `remote:`, hashes SHA1, intervalos de commit
- Status do git em português: `modified:` → "modificado", `new file:` → "novo arquivo" etc.
- Velocidade de transferência em push/pull
- Contagem de tokens e custo do Claude Code
- Códigos de escape ANSI

---

## Scripts (`scripts/`)

Scripts de configuração e instalação — em desenvolvimento.

---

## Formato dos arquivos `.dic`

Os arquivos usam formato TSV (separado por TAB):

```
padrão<TAB>substituição<TAB>sensível a maiúsc.<TAB>tipo
```

Tipos:
- `0` — correspondência simples (em qualquer lugar)
- `1` — expressão regular
- `2` — palavra inteira

Substituição vazia silencia o padrão (NVDA não lê nada no lugar).
