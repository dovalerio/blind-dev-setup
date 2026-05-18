// Symbol Navigator — navegacao estrutural por teclado, otimizado para NVDA
// Funciona com qualquer language server: Java, Kotlin, Python, TypeScript, JS, PHP
const vscode = require('vscode');

const STRUCTURAL_KINDS = new Set([
    4,  // Class
    5,  // Method
    6,  // Property  (Kotlin val/var de nivel superior)
    8,  // Constructor
    9,  // Enum
    10, // Interface
    11, // Function
]);

function activate(context) {
    context.subscriptions.push(
        vscode.commands.registerCommand('symbolNavigator.nextSymbol', () => navigate(1)),
        vscode.commands.registerCommand('symbolNavigator.prevSymbol', () => navigate(-1))
    );
}

async function navigate(direction) {
    const editor = vscode.window.activeTextEditor;
    if (!editor) return;

    let symbols;
    try {
        symbols = await vscode.commands.executeCommand(
            'vscode.executeDocumentSymbolProvider',
            editor.document.uri
        );
    } catch (_) {
        return;
    }

    if (!symbols || symbols.length === 0) {
        vscode.window.setStatusBarMessage('$(warning) Nenhum simbolo encontrado no arquivo', 2500);
        return;
    }

    const flat = flattenSymbols(symbols);
    if (flat.length === 0) return;

    const cursorLine = editor.selection.active.line;

    let targetIndex;
    if (direction > 0) {
        // Proximo: primeiro simbolo apos a linha do cursor
        targetIndex = flat.findIndex(s => getStartLine(s) > cursorLine);
        if (targetIndex === -1) targetIndex = 0; // wrap para o inicio
    } else {
        // Anterior: ultimo simbolo antes da linha do cursor
        targetIndex = -1;
        for (let i = flat.length - 1; i >= 0; i--) {
            if (getStartLine(flat[i]) < cursorLine) {
                targetIndex = i;
                break;
            }
        }
        if (targetIndex === -1) targetIndex = flat.length - 1; // wrap para o fim
    }

    const symbol = flat[targetIndex];
    const targetLine = getStartLine(symbol);
    const position = new vscode.Position(targetLine, 0);

    editor.selection = new vscode.Selection(position, position);
    editor.revealRange(
        new vscode.Range(position, position),
        vscode.TextEditorRevealType.InCenterIfOutsideViewport
    );

    // Barra de status — NVDA le via ARIA live region do VS Code
    const kindLabel = kindName(symbol.kind);
    vscode.window.setStatusBarMessage(
        `$(symbol-method) ${kindLabel}: ${symbol.name}   [${targetIndex + 1}/${flat.length}]`,
        4000
    );
}

function getStartLine(symbol) {
    if (symbol.selectionRange) return symbol.selectionRange.start.line;
    if (symbol.range) return symbol.range.start.line;
    if (symbol.location) return symbol.location.range.start.line;
    return 0;
}

function flattenSymbols(symbols) {
    const flat = [];
    function walk(syms) {
        for (const s of syms) {
            if (STRUCTURAL_KINDS.has(s.kind)) {
                flat.push(s);
            }
            const children = s.children || [];
            if (children.length > 0) walk(children);
        }
    }
    walk(symbols);
    flat.sort((a, b) => getStartLine(a) - getStartLine(b));
    return flat;
}

function kindName(kind) {
    const names = {
        4: 'Classe', 5: 'Metodo', 6: 'Propriedade',
        8: 'Construtor', 9: 'Enum', 10: 'Interface', 11: 'Funcao'
    };
    return names[kind] || 'Simbolo';
}

function deactivate() {}

module.exports = { activate, deactivate };
