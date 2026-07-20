# Spec: Dashboard

## Objetivo

Mostrar uma visao consolidada do workspace ativo usando endpoint proprio de resumo, evitando baixar dados demais no mobile.

## Endpoint

- `GET /workspaces/:workspaceId/dashboard/summary?month=7&year=2026`

## Dados

- `currentBalance`
- `totalIncluded`
- `totalOverall`
- `expensesByCategory`
- `budgetStatus`
- `accounts`

## UI

- Card de saldo consolidado.
- Indicador de total incluido vs total geral quando houver contas fora do total.
- Donut de despesas por categoria usando `color`.
- Lista/carrossel de contas ativas.
- Atalhos para nova receita/despesa.
- Link para extrato completo.
- Selector de workspace em bottom sheet.

## Estados

- Skeleton/loading.
- Empty state quando nao ha contas.
- Empty state quando nao ha despesas no mes.
- Erro com retry.

## Criterios De Aceite

- Dashboard carrega apenas com workspace ativo.
- Mudanca de workspace recarrega resumo.
- Mutacoes em contas/transacoes invalidam resumo.
- Grafico usa cores retornadas pela API.
