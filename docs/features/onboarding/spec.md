# Spec: Onboarding Financeiro

## Objetivo

Criar os workspaces iniciais e categorias padrao do usuario apos cadastro/login quando `GET /auth/me` retornar `onboardingRequired = true`.

## Endpoint

- `POST /workspaces/onboarding`

Payload:

```json
{
  "choice": "PERSONAL"
}
```

Valores:

- `PERSONAL`
- `BUSINESS`
- `BOTH`

## Fluxo

1. App detecta `onboardingRequired = true`.
2. Mostra pergunta: `Como voce deseja usar o LedgerFlow?`.
3. Usuario escolhe pessoal, negocio ou ambos.
4. App envia escolha para API.
5. API retorna `currentWorkspace` e `workspaces`.
6. App salva workspace ativo.
7. App direciona para criacao da primeira conta.

## UI

- Tela simples com tres opcoes grandes.
- Cada opcao deve mostrar icone, titulo e descricao curta.
- Botao principal habilitado apenas apos escolha.

## Estados

- Carregando escolha.
- Erro de validacao.
- Erro de API.
- Sucesso e transicao.

## Criterios De Aceite

- Usuario com onboarding pendente nao acessa dashboard.
- Escolha cria workspaces na API.
- Workspace ativo fica definido apos sucesso.
- Reabrir app depois do onboarding nao mostra a tela novamente.
