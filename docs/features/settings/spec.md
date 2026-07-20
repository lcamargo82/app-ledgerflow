# Spec: Perfil E Configuracoes

## Objetivo

Centralizar perfil, preferencias locais e acoes de seguranca.

## Endpoints

- `GET /users/profile`
- `PATCH /users/profile`
- `POST /auth/logout`

## UI

- Perfil do usuario.
- Edicao de nome e email.
- Troca de senha.
- Seletor de workspace.
- Preferencia de tema.
- Preferencia de biometria.
- Logout.

## Regras

- Biometria e preferencia local; API nao precisa conhecer no MVP.
- Tema escuro e padrao; tema claro pode ser opcional posterior.
- Logout chama API e limpa storage local mesmo se a API falhar.

## Criterios De Aceite

- Usuario ve perfil real.
- Usuario atualiza nome/email.
- Logout encerra sessao local.
- Perfil aparece como aba final da bottom navigation.
