# Spec: Workspaces

## Objetivo

Garantir isolamento de dados financeiros por workspace e permitir alternancia entre contextos como pessoal e negocio.

## Endpoints

- `GET /workspaces`
- `GET /workspaces/:workspaceId`
- `PATCH /workspaces/:workspaceId`
- `GET /workspaces/:workspaceId/members`

## Regras

- Toda rota financeira usa `workspaceId` ativo.
- Workspace ativo vem primeiro de storage local; se ausente, usar `currentWorkspace` de `/auth/me`.
- Se workspace ativo nao existir mais na lista, escolher o primeiro workspace retornado.
- Troca de workspace invalida providers financeiros.

## UI

- No MVP, selector de workspace em bottom sheet acessivel pelo Dashboard ou Perfil.
- Exibir nome, tipo e moeda.
- Evitar dropdown pequeno se houver poucos workspaces; bottom sheet e mais confortavel no mobile.

## Estados

- Loading lista de workspaces.
- Workspace vazio: levar para onboarding.
- Erro de permissao/acesso.

## Criterios De Aceite

- App nunca consulta contas/categorias/transacoes sem workspace ativo.
- Trocar workspace recarrega dashboard, contas, categorias, transacoes e relatorios.
- Workspace ativo persiste entre sessoes.
