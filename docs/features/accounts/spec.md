# Spec: Contas E Instituicoes

## Objetivo

Permitir que o usuario cadastre, visualize, edite e arquive contas/cofres dentro do workspace ativo.

## Endpoints

- `GET /institutions`
- `GET /workspaces/:workspaceId/accounts`
- `POST /workspaces/:workspaceId/accounts`
- `GET /workspaces/:workspaceId/accounts/:accountId`
- `PATCH /workspaces/:workspaceId/accounts/:accountId`
- `DELETE /workspaces/:workspaceId/accounts/:accountId`

## Campos Da Conta

- `name`
- `description`
- `type`: `CHECKING`, `SAVINGS`, `WALLET`, `INVESTMENT`, `BENEFITS`, `CREDIT_CARD`, `OTHER`
- `institutionId`
- `color`
- `icon`
- `includeInTotal`
- `initialBalance` apenas na criacao
- `balance` retornado pela API

## Regras

- Instituicoes devem vir de `GET /institutions`.
- `initialBalance` cria transacao genesis no backend; o app nao cria transacao manual para isso.
- Arquivar conta nao apaga historico.
- Contas com `includeInTotal = false` aparecem, mas nao entram no saldo total.

## UI

- Lista de contas com saldo, instituicao/tipo, icone e cor.
- Formulario de criar/editar conta.
- Seletor de instituicao com busca.
- Toggle `Incluir no saldo total`.
- Tela especial de primeira conta apos onboarding.

## Criterios De Aceite

- Usuario cria conta real com saldo inicial.
- Lista mostra `balance` retornado pela API.
- Dashboard atualiza apos criar/editar/arquivar conta.
- Instituicoes nao sao hardcoded no app.
