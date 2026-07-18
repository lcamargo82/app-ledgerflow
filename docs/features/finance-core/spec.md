# Feature Spec: Nucleo Financeiro

## Objetivo

Permitir que o usuario organize sua vida financeira em contas, categorias, transacoes e transferencias.

## Entidades Iniciais

### Conta

Representa carteira, conta corrente, cartao, investimento ou dinheiro.

Campos sugeridos:

- `id`
- `name`
- `type`: checking, savings, credit_card, cash, investment
- `institutionName`
- `currentBalance`
- `availableLimit`
- `currency`
- `color`
- `icon`
- `active`

### Categoria

Representa agrupamento de receitas/despesas.

Campos sugeridos:

- `id`
- `name`
- `type`: income, expense, both
- `description`
- `icon`
- `color`
- `budgetLimit`
- `active`

### Transacao

Campos sugeridos:

- `id`
- `type`: income, expense
- `amount`
- `description`
- `date`
- `accountId`
- `categoryId`
- `status`: pending, completed, canceled
- `notes`
- `createdAt`
- `updatedAt`

### Transferencia

Campos sugeridos:

- `id`
- `fromAccountId`
- `toAccountId`
- `amount`
- `date`
- `description`
- `status`

## Fluxos

### Criar Despesa

1. Usuario toca em adicionar despesa.
2. Informa valor, descricao, categoria, conta e data.
3. App valida valor maior que zero.
4. App envia para API.
5. Dashboard e lista de transacoes sao atualizados.

### Criar Receita

Similar a despesa, mas soma no saldo e usa categorias de receita.

### Transferir Entre Contas

1. Usuario escolhe conta origem e destino.
2. Informa valor e data.
3. App impede origem igual ao destino.
4. App registra transferencia.
5. Saldos das contas sao recalculados.

## Telas

- Nova transacao
- Detalhes da transacao
- Minhas contas
- Gerenciar categorias
- Transferencia entre contas

## Criterios De Aceite

- Usuario cria uma despesa com categoria e conta.
- Usuario cria uma receita.
- Usuario visualiza detalhes de uma transacao.
- Usuario cadastra/edita/desativa uma categoria.
- Usuario cadastra/edita/desativa uma conta.
- Usuario faz transferencia entre contas diferentes.
- Dashboard reflete mudancas apos criar transacoes.

