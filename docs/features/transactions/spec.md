# Spec: Transacoes

## Objetivo

Registrar receitas e despesas manuais, listar extrato paginado e proteger transacoes sistemicas.

## Endpoints

- `GET /workspaces/:workspaceId/transactions/monthly-summary`
- `GET /workspaces/:workspaceId/transactions`
- `POST /workspaces/:workspaceId/transactions`
- `GET /workspaces/:workspaceId/transactions/:transactionId`
- `PATCH /workspaces/:workspaceId/transactions/:transactionId`
- `DELETE /workspaces/:workspaceId/transactions/:transactionId`

## Campos

- `accountId`
- `categoryId`
- `type`: `INCOME`, `EXPENSE`
- `origin`: `MANUAL`, `INITIAL_BALANCE`
- `amount`
- `occurredAt`
- `description`

## Regras

- `amount` deve ser positivo no payload.
- Tipo define sinal visual: `INCOME` positivo, `EXPENSE` negativo.
- Categoria deve ser compativel com o tipo.
- `origin = INITIAL_BALANCE` nao pode ser editado/removido pela UI.
- Extrato vem flat da API; agrupamento por dia acontece no Flutter.

## UI

- Lista mensal com filtros.
- Cards agrupados por dia.
- Bottom sheet/tela de nova transacao.
- Detalhe da transacao.
- Swipe/acoes somente para transacoes `MANUAL`.

## Criterios De Aceite

- Usuario cria receita e despesa.
- Extrato pagina corretamente.
- Dashboard e contas atualizam apos mutacao.
- Transacoes genesis aparecem protegidas.
