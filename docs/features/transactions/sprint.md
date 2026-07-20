# Sprint: Transacoes

## Objetivo

Entregar extrato real e lancamento manual de receitas/despesas.

## Tarefas

- [ ] Criar modelos `Transaction`, `TransactionPage`, `MonthlySummary`.
- [ ] Criar enums `TransactionType` e `TransactionOrigin`.
- [ ] Criar `TransactionsApi`.
- [ ] Criar `TransactionsRepository`.
- [ ] Criar providers com filtros e paginacao.
- [ ] Criar agrupador por dia no client.
- [ ] Conectar tela de transacoes a API.
- [ ] Implementar formulario de nova transacao.
- [ ] Implementar detalhe de transacao.
- [ ] Implementar edicao/remocao somente para `MANUAL`.
- [ ] Invalidar dashboard, contas e relatorios apos mutacoes.
- [ ] Testar parser, agrupamento e protecao de origin.

## Definicao De Pronto

- Receita/despesa manual funciona contra API.
- Extrato mostra loading, empty, erro e paginacao.
- Transacoes `INITIAL_BALANCE` nao oferecem editar/remover.
