# Spec: Categorias

## Objetivo

Permitir gerenciar categorias de receita e despesa por workspace, respeitando categorias sistemicas e defaults da API.

## Endpoints

- `GET /workspaces/:workspaceId/categories`
- `POST /workspaces/:workspaceId/categories`
- `GET /workspaces/:workspaceId/categories/:categoryId`
- `PATCH /workspaces/:workspaceId/categories/:categoryId`
- `DELETE /workspaces/:workspaceId/categories/:categoryId`

## Campos

- `name`
- `type`: `INCOME`, `EXPENSE`, `ADJUSTMENT`
- `color`
- `icon`
- `isSystemDefault`
- `active`

## Regras

- Criacao permite apenas `INCOME` ou `EXPENSE`.
- Categorias `ADJUSTMENT` nao aparecem em seletores comuns.
- Categorias sistemicas nao devem oferecer acao destrutiva se a API bloquear.
- Ao selecionar categoria em transacao, tipo deve coincidir com tipo da transacao.

## UI

- Tela com tabs: Receitas e Despesas.
- Busca por nome.
- Formulario com nome, tipo, cor e icone.
- Swatches de cor.
- Grid/lista de icones mapeados.

## Criterios De Aceite

- Usuario lista, cria, edita e remove/arquiva categorias.
- Seletores de transacao filtram por tipo.
- Categorias sistemicas ficam protegidas visualmente.
