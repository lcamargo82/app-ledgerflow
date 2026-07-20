# Sprint: Autenticacao E Perfil

## Objetivo

Conectar as telas de autenticacao existentes a API real e estabelecer a base de sessao segura do app.

## Tarefas

- [ ] Adicionar dependencias `dio` e `flutter_secure_storage`.
- [ ] Criar `AppConfig` com `API_BASE_URL` via `--dart-define`.
- [ ] Criar `SecureTokenStorage`.
- [ ] Criar `DioClient` com base URL, timeouts e interceptor de token.
- [ ] Criar parser de erro padronizado da API.
- [ ] Criar modelos `AuthTokens`, `UserProfile`, `WorkspaceSummary` e `AuthMe`.
- [ ] Criar `AuthApi`.
- [ ] Criar `AuthRepository`.
- [ ] Criar `AuthController` com `boot`, `login`, `signup`, `refresh`, `logout`, `forgotPassword` e `resetPassword`.
- [ ] Configurar `GoRouter.redirect` baseado em estado de sessao.
- [ ] Conectar tela de login.
- [ ] Conectar tela de cadastro.
- [ ] Conectar tela de recuperacao de senha.
- [ ] Criar/ajustar tela de perfil para `GET /users/profile` e `PATCH /users/profile`.
- [ ] Exibir loading e erros por snackbar/dialog.
- [ ] Criar testes de models/parsers.
- [ ] Criar testes de controller para boot, login, refresh falho e logout.

## Definicao De Pronto

- `flutter analyze` sem issues.
- `flutter test` passando.
- Login real funciona contra producao ou local configurado.
- Sessao persiste ao fechar e abrir o app.
- Sessao expirada volta para login sem loop.
