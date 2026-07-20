# API Endpoints Consumidos Pelo App

Base URL de producao:

```text
https://api-appledgerflow.lcamargo.dev.br
```

Base local:

```text
http://localhost:3020
```

Todos os endpoints abaixo, exceto auth publico, usam `Authorization: Bearer <accessToken>`.

## Auth

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /auth/me`

`GET /auth/me` retorna tambem:

- `onboardingRequired`
- `currentWorkspace`
- `workspaces`

## Users

- `GET /users/profile`
- `PATCH /users/profile`

Campos editaveis:

- `name`
- `email`
- `oldPassword`
- `password`

## Workspaces

- `GET /workspaces`
- `POST /workspaces/onboarding`
- `GET /workspaces/:workspaceId`
- `PATCH /workspaces/:workspaceId`
- `GET /workspaces/:workspaceId/members`

Onboarding:

```json
{
  "choice": "PERSONAL"
}
```

Valores validos:

- `PERSONAL`
- `BUSINESS`
- `BOTH`

## Institutions

- `GET /institutions`

Query params:

- `type`: `BANK`, `DIGITAL_BANK`, `BENEFITS`, `BROKER`, `PAYMENT_INSTITUTION`, `OTHER`
- `search`
- `includeInactive`

## Accounts

- `GET /workspaces/:workspaceId/accounts`
- `POST /workspaces/:workspaceId/accounts`
- `GET /workspaces/:workspaceId/accounts/:accountId`
- `PATCH /workspaces/:workspaceId/accounts/:accountId`
- `DELETE /workspaces/:workspaceId/accounts/:accountId`

Criacao:

```json
{
  "name": "Conta Principal",
  "description": "Conta usada para despesas do mes",
  "type": "CHECKING",
  "institutionId": "nubank",
  "color": "#7C3AED",
  "icon": "bank",
  "includeInTotal": true,
  "initialBalance": 5000
}
```

Tipos de conta:

- `CHECKING`
- `SAVINGS`
- `WALLET`
- `INVESTMENT`
- `BENEFITS`
- `CREDIT_CARD`
- `OTHER`

## Categories

- `GET /workspaces/:workspaceId/categories`
- `POST /workspaces/:workspaceId/categories`
- `GET /workspaces/:workspaceId/categories/:categoryId`
- `PATCH /workspaces/:workspaceId/categories/:categoryId`
- `DELETE /workspaces/:workspaceId/categories/:categoryId`

Query params:

- `type`: `INCOME`, `EXPENSE`, `ADJUSTMENT`
- `active`
- `includeSystem`
- `search`

Criacao:

```json
{
  "name": "Alimentacao",
  "type": "EXPENSE",
  "color": "#EF4444",
  "icon": "utensils"
}
```

## Transactions

- `GET /workspaces/:workspaceId/transactions/monthly-summary`
- `GET /workspaces/:workspaceId/transactions`
- `POST /workspaces/:workspaceId/transactions`
- `GET /workspaces/:workspaceId/transactions/:transactionId`
- `PATCH /workspaces/:workspaceId/transactions/:transactionId`
- `DELETE /workspaces/:workspaceId/transactions/:transactionId`

Filtros do extrato:

- `accountId`
- `categoryId`
- `type`: `INCOME`, `EXPENSE`
- `origin`: `MANUAL`, `INITIAL_BALANCE`
- `startDate`
- `endDate`
- `search`
- `page`
- `perPage`

Criacao:

```json
{
  "accountId": "account-id",
  "categoryId": "category-id",
  "type": "EXPENSE",
  "amount": 150.5,
  "occurredAt": "2026-07-19T12:00:00.000Z",
  "description": "Jantar"
}
```

## Dashboard

- `GET /workspaces/:workspaceId/dashboard/summary`

Query params:

- `month`
- `year`

Resposta contem:

- `currentBalance`
- `totalIncluded`
- `totalOverall`
- `expensesByCategory`
- `budgetStatus`
- `accounts`

## Health

- `GET /health`
- `GET /health/liveness`
- `GET /health/readiness`
