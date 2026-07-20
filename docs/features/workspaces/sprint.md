# Sprint: Workspaces

## Objetivo

Criar estado global de workspace ativo e invalidacao de dados financeiros.

## Tarefas

- [ ] Criar `WorkspaceSummary` e `WorkspaceMember`.
- [ ] Criar `WorkspaceApi`.
- [ ] Criar `WorkspaceRepository`.
- [ ] Criar `WorkspaceController`.
- [ ] Criar storage do `activeWorkspaceId`.
- [ ] Criar provider `activeWorkspaceProvider`.
- [ ] Criar bottom sheet de troca de workspace.
- [ ] Integrar selector ao Dashboard/Perfil.
- [ ] Invalidar providers financeiros ao trocar workspace.
- [ ] Testar fallback quando workspace salvo nao existe mais.

## Definicao De Pronto

- Toda feature financeira depende de `activeWorkspaceId`.
- Troca de workspace nao reaproveita dados antigos na UI.
