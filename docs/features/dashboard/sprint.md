# Sprint: Dashboard

## Objetivo

Trocar dashboard mockado pelo resumo real da API.

## Tarefas

- [ ] Criar modelo `DashboardSummary`.
- [ ] Criar modelo `ExpenseByCategory`.
- [ ] Criar modelo resumido de conta do dashboard.
- [ ] Criar `DashboardApi`.
- [ ] Criar `DashboardRepository`.
- [ ] Criar provider por workspace/mes/ano.
- [ ] Conectar card de saldo ao `totalIncluded`.
- [ ] Conectar grafico donut ao `expensesByCategory`.
- [ ] Conectar contas ativas.
- [ ] Criar empty state sem contas.
- [ ] Criar retry em erro.
- [ ] Testar parser de valores monetarios e categorias.

## Definicao De Pronto

- Dashboard mostra dados reais do workspace.
- Requests usam `month` e `year`.
- UI responde corretamente a workspace vazio e erro.
