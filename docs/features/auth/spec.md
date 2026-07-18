# Feature Spec: Autenticacao E Perfil

## Objetivo

Permitir que o usuario crie conta, faca login, mantenha sessao ativa com refresh token, recupere senha, edite perfil e encerre a sessao com seguranca.

## Backend Disponivel

Base local:

```text
http://localhost:3020
```

Endpoints:

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /auth/me`
- `GET /users/profile`
- `PATCH /users/profile`

## Modelo De Sessao

Resposta esperada em signup/login/refresh:

```json
{
  "accessToken": "jwt-token",
  "refreshToken": "refresh-token",
  "tokenType": "Bearer",
  "expiresIn": "15m",
  "refreshExpiresIn": "7d",
  "user": {
    "id": "uuid",
    "email": "leandro@example.com",
    "name": "Leandro Silva",
    "active": true,
    "tokenVersion": 0,
    "createdAt": "2026-07-18T12:00:00.000Z",
    "updatedAt": "2026-07-18T12:00:00.000Z"
  }
}
```

## Fluxos

### Cadastro

1. Usuario informa nome, email e senha.
2. App valida campos localmente.
3. App chama `POST /auth/signup`.
4. App salva tokens em armazenamento seguro.
5. App redireciona para criacao/complemento de perfil ou dashboard.

### Login

1. Usuario informa email e senha.
2. App chama `POST /auth/login`.
3. App salva access token e refresh token.
4. App carrega perfil e abre dashboard.

### Boot Do App

1. App abre splash.
2. App le refresh token do armazenamento seguro.
3. Se existir, tenta `POST /auth/refresh`.
4. Se renovar, entra no dashboard.
5. Se falhar, limpa tokens e abre login.

### Logout

1. Usuario toca em sair.
2. App chama `POST /auth/logout` com access token.
3. App limpa tokens localmente.
4. App volta para login.

Se a API falhar no logout, o app ainda deve limpar a sessao local.

### Perfil

1. App chama `GET /users/profile`.
2. Usuario edita nome, email ou senha.
3. App chama `PATCH /users/profile`.
4. App atualiza estado local.

## Estados De UI

- idle
- loading
- success
- invalid input
- unauthorized
- network error
- server error

## Validacoes Iniciais

- email obrigatorio e valido;
- senha obrigatoria;
- senha de cadastro/reset com tamanho minimo definido pela API;
- nome obrigatorio no cadastro/perfil;
- mensagens de erro simples e localizadas em portugues.

## Decisoes Flutter

- `AuthRepository` para falar com a API.
- `AuthController` Riverpod para coordenar estados.
- `SecureTokenStorage` para tokens.
- `Dio` interceptor para incluir bearer token.
- Redirect no `go_router` para proteger rotas autenticadas.

## Criterios De Aceite

- Usuario consegue cadastrar e cair em uma area autenticada.
- Usuario consegue logar apos fechar e abrir o app.
- Access token expirado e renovado silenciosamente com refresh token.
- Refresh invalido limpa sessao e envia para login.
- Logout remove tokens locais mesmo se a API estiver indisponivel.
- Perfil autenticado carrega e pode ser atualizado.

