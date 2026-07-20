# Spec: Relatorios

## Objetivo

Exibir relatorios mensais simples para ajudar o usuario a entender receitas, despesas e categorias de maior impacto.

## Endpoints Iniciais

- `GET /workspaces/:workspaceId/transactions/monthly-summary`
- `GET /workspaces/:workspaceId/dashboard/summary`
- `GET /workspaces/:workspaceId/transactions` com filtros por periodo

## UI

- Seletor de mes/ano.
- Cards: saldo atual, saldo mensal, receitas, despesas.
- Barras ou comparativo de receitas vs despesas.
- Ranking de despesas por categoria usando `expensesByCategory`.
- Lista filtrada por periodo para drill-down simples.

## Regras

- Relatorios dependem do workspace ativo.
- Deve haver loading e retry.
- Valores devem ser formatados em BRL.
- Se nao houver dados, mostrar empty state util.

## Criterios De Aceite

- Usuario visualiza consolidado mensal real.
- Troca de mes/ano recarrega dados.
- Troca de workspace limpa dados anteriores.
