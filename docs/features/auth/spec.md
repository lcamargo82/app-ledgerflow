# Spec: Autenticacao E Perfil

## Objetivo

Entregar a entrada real do app: cadastro, login, boot de sessao, refresh token, recuperacao de senha, perfil e logout.

## Endpoints

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /auth/me`
- `GET /users/profile`
- `PATCH /users/profile`

## Fluxo De Boot

1. App abre em splash.
2. Lê access token e refresh token do storage seguro.
3. Sem tokens: navega para `/login`.
4. Com access token: chama `GET /auth/me`.
5. Se `401`, tenta `POST /auth/refresh`.
6. Se refresh falhar, limpa storage e navega para `/login`.
7. Se `onboardingRequired = true`, navega para `/onboarding`.
8. Se existe `currentWorkspace`, entra no shell autenticado.

## Modelos

- `AuthTokens`: `accessToken`, `refreshToken`, `tokenType`, `expiresIn`, `refreshExpiresIn`.
- `UserProfile`: `id`, `email`, `name`, `active`, `tokenVersion`, `createdAt`, `updatedAt`.
- `AuthMe`: `sub`, `email`, `tokenVersion`, `onboardingRequired`, `currentWorkspace`, `workspaces`.

## UI

- Login com email, senha, lembrar de mim e biometria visual.
- Cadastro com nome, email e senha.
- Recuperacao de senha com email.
- Perfil com dados do usuario e acao de alterar nome/email/senha.
- Logout na tela de Perfil.

## Validacoes

- Email valido.
- Senha obrigatoria no login.
- Cadastro exige nome, email e senha.
- Troca de senha exige senha atual quando nova senha for informada.

## Estados

- Idle
- Loading
- Success
- Validation error
- API error
- Session expired

## Criterios De Aceite

- Usuario consegue cadastrar e logar contra a API.
- Tokens ficam apenas no storage seguro.
- `GET /auth/me` decide onboarding/dashboard.
- Refresh token ocorre uma vez por `401`.
- Logout limpa storage e estado Riverpod.
