# Sprint: Autenticacao E Perfil

## Objetivo

Entregar a base real de entrada do app Flutter: login, cadastro, recuperacao de senha, sessao persistida, perfil e logout.

## Tarefas

- [ ] Criar estrutura `lib/src`.
- [ ] Criar `AppConfig` com base URL local.
- [ ] Adicionar dependencias iniciais: `go_router`, `flutter_riverpod`, `dio`, `flutter_secure_storage`, `google_fonts`.
- [ ] Criar tema escuro inicial baseado em `docs/design/design-system.md`.
- [ ] Criar `AuthSession`, `UserProfile` e modelos de request/response.
- [ ] Criar `SecureTokenStorage`.
- [ ] Criar `DioClient` com base URL, timeouts e interceptor de token.
- [ ] Criar `AuthRepository`.
- [ ] Criar `AuthController` com login, signup, refresh, logout e boot.
- [ ] Configurar `go_router` com rotas publicas e autenticadas.
- [ ] Implementar telas de login, cadastro e esqueci senha.
- [ ] Implementar tela de perfil/configuracoes basica.
- [ ] Implementar estados de loading, erro e sucesso.
- [ ] Escrever testes unitarios de parser/modelos.
- [ ] Escrever testes de controller para login/logout/refresh.

## Definicao De Pronto

- App abre em splash e decide login/dashboard com base na sessao.
- Login e cadastro funcionam contra `http://localhost:3020`.
- Tokens nao ficam em memoria permanente sem armazenamento seguro.
- Logout limpa sessao local.
- Erros de API aparecem de forma compreensivel.

