# Software Design Document (SDD)

## Estado Atual Do Projeto

O app Flutter ainda esta no scaffold inicial criado pelo Flutter:

- `lib/main.dart` contem o contador padrao.
- `pubspec.yaml` possui apenas `flutter`, `cupertino_icons` e `flutter_lints`.
- Ainda nao ha pasta `lib/src` ou arquitetura de features.
- A pasta atual nao parece estar inicializada como repositorio Git.

## Backend

API local esperada pelo app:

```text
http://localhost:3020
```

API encontrada no ambiente:

```text
/Users/leandro/Documents/Projetos/Node/api-ledgerflow
```

Stack identificada:

- NestJS 11
- Prisma
- PostgreSQL
- JWT com access token
- Refresh token persistido e rotacionado
- Swagger configurado na API

Endpoints ja existentes:

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /auth/me`
- `GET /users/profile`
- `PATCH /users/profile`
- `GET /health`

## Arquitetura Flutter Recomendada

Comecar simples, mas com fronteiras claras:

```text
lib/
  main.dart
  src/
    app/
      app.dart
      router.dart
      theme/
    core/
      config/
      network/
      storage/
      errors/
      widgets/
    features/
      auth/
      dashboard/
      accounts/
      categories/
      transactions/
      reports/
      settings/
```

### Camadas Por Feature

```text
features/auth/
  data/
    auth_api.dart
    auth_repository.dart
    models/
  domain/
    auth_session.dart
    user_profile.dart
  presentation/
    login_screen.dart
    signup_screen.dart
    forgot_password_screen.dart
    profile_screen.dart
    auth_controller.dart
```

Essa divisao e suficiente para aprender Flutter sem criar uma arquitetura pesada demais.

## Bibliotecas Recomendadas

As recomendacoes abaixo foram conferidas em pub.dev em 2026-07-18.

- Roteamento: `go_router`
  - Bom para deep links, rotas declarativas, redirects de autenticacao e shell com bottom navigation.
- Estado: `flutter_riverpod`
  - Bom para estado assincrono, cache de requests e separacao entre UI e logica.
- HTTP: `dio`
  - Bom para interceptors, timeouts, refresh token, tratamento centralizado de erro e cancelamento.
- Tokens: `flutter_secure_storage`
  - Armazena credenciais em Keychain/Keystore ou equivalentes.
- Graficos: `fl_chart`
  - Cobre pizza/donut, barras e linhas com customizacao suficiente para dashboard financeiro.
- Fonte: `google_fonts` ou fonte Inter local em assets
  - `google_fonts` acelera o inicio; fonte local melhora previsibilidade offline.
- Animacoes pontuais: `lottie`
  - Usar apenas para empty states, sucesso e onboarding leve. Evitar animar dashboards densos.

## Decisoes De Produto/Tecnologia

### Tema

Usar Material 3 com tema escuro como padrao inicial, baseado no design "Precision Dark". Manter tema claro como opcional futuro, nao como prioridade do MVP.

### Icones

O design usa Material Symbols. No Flutter, comecar com `Icons` do Material para reduzir dependencias. Se a linguagem visual pedir icones mais finos e consistentes, avaliar `phosphor_flutter` ou `phosphoricons_flutter`.

### Navegacao

Usar `go_router` com:

- rotas publicas: splash, login, cadastro, esqueci senha, reset senha;
- rotas autenticadas: dashboard, transacoes, relatorios, contas, categorias, configuracoes;
- redirect baseado no estado de sessao;
- `ShellRoute` para manter bottom navigation.

### Estado

Usar Riverpod:

- `AuthController` para login/logout/refresh;
- providers por feature para listar transacoes, contas, categorias e relatorios;
- evitar Provider global unico com estado demais.

### Rede

Criar um cliente `Dio` central com:

- `baseUrl` por ambiente;
- interceptor para `Authorization: Bearer <accessToken>`;
- refresh automatico uma vez quando receber `401`;
- logout local quando refresh falhar;
- timeouts explicitos.

Observacao importante para emuladores:

- Android Emulator acessa a maquina host por `http://10.0.2.2:3020`.
- iOS Simulator geralmente consegue usar `http://localhost:3020`.
- Dispositivo fisico precisa do IP local da maquina.

### Persistencia

MVP:

- access token e refresh token em `flutter_secure_storage`;
- perfil em memoria/estado, recarregado no boot.

Depois:

- cache local com Drift ou Isar para transacoes, contas e categorias.

### Graficos

Usar `fl_chart` para:

- donut/pie de despesas por categoria;
- barras de receitas vs despesas por mes;
- linha de saldo ao longo do tempo;
- progresso de orcamento por categoria.

### Animacoes E Transicoes

Comecar com animacoes nativas:

- `AnimatedSwitcher` para troca de loading/conteudo;
- `Hero` apenas onde houver continuidade visual real;
- bottom sheets com Material motion;
- transicoes de rota discretas, 180-240ms;
- Lottie apenas para estados vazios ou sucesso.

## Ambientes

Criar configuracao por flavor/ambiente posteriormente:

- `dev`: API local
- `staging`: API de homologacao
- `prod`: API publica

No inicio, uma constante central em `core/config/app_config.dart` e suficiente.

## Qualidade

Testes iniciais recomendados:

- unitarios para parsers/modelos e repositories;
- testes de controller Riverpod para login/logout;
- widget tests para telas de auth e formularios;
- golden tests depois que o design estabilizar.

## Riscos

- Tema escuro bonito pode esconder problemas de contraste em textos secundarios.
- Refresh token mal tratado pode prender usuario em loop de login.
- Graficos podem ficar bonitos, mas pouco explicativos; labels e legenda importam.
- Comecar com arquitetura complexa demais pode atrapalhar o aprendizado. Melhor crescer por features.

## Referencias

- Design ZIP: `/Users/leandro/Downloads/stitch_ledgerflow_personal_finance_ui.zip`
- API: `/Users/leandro/Documents/Projetos/Node/api-ledgerflow`
- go_router: https://pub.dev/packages/go_router
- flutter_riverpod: https://pub.dev/packages/flutter_riverpod
- dio: https://pub.dev/packages/dio
- flutter_secure_storage: https://pub.dev/packages/flutter_secure_storage
- fl_chart: https://pub.dev/packages/fl_chart
- lottie: https://pub.dev/packages/lottie

