# Design System

## Origem

Sistema visual extraido dos arquivos de referencia:

```text
/Users/leandro/Downloads/stitch_ledgerflow_personal_finance_ui.zip
/Users/leandro/Downloads/stitch_ledgerflow_personal_finance_ui (1).zip
```

Os ZIPs contem um documento `precision_dark/DESIGN.md` e telas HTML exportadas.

## Direcao Visual

Nome observado: Precision Dark.

Personalidade:

- profissional;
- moderna;
- analitica;
- confiavel;
- escura por padrao;
- com cores vibrantes reservadas para acoes e dados financeiros.

## Cores Base

Principais tokens observados:

```text
background: #13121b
surface: #13121b
surface-container-lowest: #0e0d16
surface-container-low: #1b1b24
surface-container: #1f1f28
surface-container-high: #2a2933
surface-container-highest: #35343e
on-surface: #e4e1ee
on-surface-variant: #c7c4d8
outline: #918fa1
outline-variant: #464555
primary: #c3c0ff
primary-container: #4f46e5
secondary-container: #0566d9
tertiary: #4cd7f6
error: #ffb4ab
error-container: #93000a
```

Cores adicionais usadas nos exemplos:

```text
indigo: #4f46e5
blue: #3b82f6
cyan: #06b6d4
emerald: #10b981
```

## Uso Semantico De Cores

- Indigo/azul: marca, navegacao ativa, acoes primarias, despesas/investimentos.
- Ciano: informacao financeira, despesas e destaques de grafico.
- Esmeralda: receitas, crescimento, sucesso e saldos positivos.
- Vermelho/coral: erro, risco, orcamento estourado e exclusao.
- Neutros escuros: fundo, cards, inputs e bottom navigation.

## Tipografia

Fonte observada: Inter.

Escala principal:

```text
headline-lg: 32 / 40, weight 600
headline-lg-mobile: 28 / 36, weight 600
headline-md: 24 / 32, weight 500
headline-sm: 20 / 28, weight 500
body-lg: 16 / 24, weight 400
body-md: 14 / 20, weight 400
label-md: 12 / 16, weight 500
```

Recomendacao Flutter:

- usar `TextTheme` do Material 3 mapeado para essa escala;
- evitar letter spacing negativo no app, mesmo que apareca no HTML;
- formatar valores monetarios com peso 600 e alinhamento consistente.

## Formas E Espacamento

Grid:

- base: 4px
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- margem mobile: 16px
- gutter mobile: 12px

Raios:

- botoes, inputs e itens pequenos: 8px
- cards principais e bottom sheets: 12-16px
- indicadores/progress bars: pill

## Componentes Chave

### App Bar

- fundo escuro com borda inferior sutil;
- marca `LedgerFlow`;
- icone de carteira/banco;
- avatar ou atalho de perfil no canto direito.

### Bottom Navigation

Abas iniciais:

- Home
- Transacoes
- Relatorios
- Configuracoes

Contas e categorias podem entrar por Configuracoes ou atalhos do dashboard no MVP.

### Cards

- fundo em `surface-container` ou `surface-container-high`;
- borda de 1px quando precisar separar;
- sem sombras pesadas;
- padding interno de 16px;
- usados para saldo, transacoes, contas e blocos de relatorio.

### Inputs

- fundo tonal escuro;
- borda sutil;
- foco com indigo;
- labels sempre visiveis em formularios financeiros.

### Graficos

- donut para categorias;
- barras para receitas vs despesas;
- progress bars para orcamentos;
- legendas sempre proximas ao grafico.

## Telas E Padroes Observados

Dashboard:

- saldo total;
- variacao mensal;
- atalhos para receita/despesa;
- donut de despesas por categoria;
- transacoes recentes.

Relatorios:

- receitas vs despesas;
- orcamentos mensais por categoria;
- progresso percentual;
- alerta visual quando passa de 100%.

Nova transacao:

- valor;
- descricao;
- categoria;
- conta/carteira;
- data.

Minhas contas:

- lista de contas;
- saldo disponivel/patrimonio/limite;
- CTA para adicionar conta.

Configuracoes:

- dados pessoais;
- contas bancarias;
- moeda;
- tema escuro;
- notificacoes;
- senha;
- biometria;
- logout.
