# Software Design Document (SDD)

## Estado Atual Do Projeto

O app Flutter ja possui uma primeira base de telas mockadas em `lib/src`, com tema escuro, `go_router`, `flutter_riverpod`, `google_fonts` e `fl_chart`.

O proximo marco e conectar essa base visual a API real, respeitando sessao, onboarding e workspace ativo.

## Backend

Base URL de producao:

```text
https://api-appledgerflow.lcamargo.dev.br
```

Base URL local:

```text
http://localhost:3020
```

Android Emulator:

```text
http://10.0.2.2:3020
```

API para consulta local:

```text
/Users/leandro/Documents/Projetos/Node/api-ledgerflow
```

Stack identificada:

- NestJS
- Prisma
- PostgreSQL
- JWT com access token
- Refresh token persistido e rotacionado
- Swagger configurado na API

## Arquitetura Flutter

Estrutura alvo:

```text
lib/
  main.dart
  src/
    app/
      app.dart
      router.dart
      shell/
      theme/
    core/
      config/
      errors/
      formatting/
      network/
      storage/
      widgets/
    features/
      auth/
      onboarding/
      workspaces/
      accounts/
      categories/
      transactions/
      dashboard/
      reports/
      settings/
```

Padrao por feature:

```text
features/<feature>/
  data/
    models/
    <feature>_api.dart
    <feature>_repository.dart
  domain/
    entities.dart
  presentation/
    controllers/
    screens/
    widgets/
```

## Bibliotecas

Ja adicionadas:

- `go_router`: rotas declarativas e redirects por sessao/onboarding.
- `flutter_riverpod`: estado assincrono, cache e invalidacao por feature.
- `google_fonts`: Inter no tema inicial.
- `fl_chart`: graficos de dashboard e relatorios.

Adicionar quando iniciar integracao real:

- `dio`: HTTP, interceptors, refresh token e erros centralizados.
- `flutter_secure_storage`: storage seguro de access/refresh token.
- Opcional depois: `intl` para moeda/data; `mocktail` para testes unitarios.

## Configuracao De Ambiente

Criar `AppConfig` com ambientes:

```text
devLocal: http://localhost:3020
devAndroid: http://10.0.2.2:3020
production: https://api-appledgerflow.lcamargo.dev.br
```

No inicio, usar `--dart-define=API_BASE_URL=...`:

```bash
flutter run --dart-define=API_BASE_URL=https://api-appledgerflow.lcamargo.dev.br
```

Fallback:

- iOS simulator/web/desktop: `http://localhost:3020`
- Android emulator: `http://10.0.2.2:3020`
- release/producao: URL de producao

## Navegacao

Rotas publicas:

- `/login`
- `/signup`
- `/forgot-password`
- `/reset-password`

Rotas de boot/onboarding:

- `/splash`
- `/onboarding`
- `/accounts/first`

Rotas autenticadas:

- `/dashboard`
- `/transactions`
- `/transactions/new`
- `/transactions/:id`
- `/reports`
- `/accounts`
- `/categories`
- `/settings`

Usar `GoRouter.redirect` com estado Riverpod:

- Sem token valido: rotas autenticadas redirecionam para `/login`.
- Com token e `onboardingRequired = true`: redirecionar para `/onboarding`.
- Com onboarding completo e sem conta: sugerir `/accounts/first`.
- Com workspace ativo: liberar shell autenticado.

## Estado

Providers principais:

- `secureTokenStorageProvider`
- `dioProvider`
- `authRepositoryProvider`
- `authControllerProvider`
- `workspaceControllerProvider`
- `activeWorkspaceProvider`
- `dashboardSummaryProvider`
- `accountsProvider`
- `institutionsProvider`
- `categoriesProvider`
- `transactionsProvider`

Regra importante:

Quando `activeWorkspaceId` mudar, invalidar dashboard, contas, categorias, transacoes e relatorios.

## Rede

Criar `DioClient` com:

- `baseUrl` por ambiente.
- `Authorization: Bearer <accessToken>`.
- timeouts explicitos.
- parse de erro padronizado.
- refresh automatico uma unica vez ao receber `401`.
- logout local se refresh falhar.

Erros da API:

- Mostrar `message` quando existir.
- Para erros tecnicos ou sem mensagem, exibir: `Ocorreu um erro inesperado. Tente novamente.`

## Persistencia Local

MVP:

- access token e refresh token em `flutter_secure_storage`.
- workspace ativo em storage seguro ou shared preferences; por simplicidade, pode ficar no storage seguro junto da sessao.
- perfil e dados financeiros em memoria Riverpod.

Depois:

- cache local com Drift/Isar para transacoes, contas e categorias.

## Modelagem Monetaria

A API retorna muitos valores decimais como string, por exemplo `balance: "5000.00"`.

No Flutter:

- Criar `Money` ou helpers para parse seguro de `String` para centavos inteiros.
- Evitar `double` como fonte de verdade para calculos financeiros.
- Formatar exibicao em BRL na UI.

## Icones Dinamicos

A API usa chaves string como `bank`, `utensils`, `tag`.

No Flutter:

- Criar `LedgerIconMapper` com fallback para `Icons.category_outlined`.
- Manter mapeamento centralizado para contas, categorias e instituicoes.
- Evitar salvar `IconData` em modelos de dominio.

## Graficos

Usar `fl_chart` para:

- donut de despesas por categoria via `expensesByCategory`;
- barras mensais de receitas vs despesas via consolidadores;
- progresso de orcamentos quando API expuser planejamento.

## Testes

Prioridade:

- unitarios para models/parsers, principalmente dinheiro e datas;
- unitarios de repositories com Dio mockado;
- testes de controller Riverpod para login, boot, refresh e troca de workspace;
- widget tests para login, onboarding, primeira conta e nova transacao.

## Riscos

- Refresh token mal tratado pode prender usuario em loop.
- Troca de workspace sem invalidacao pode mostrar dados do workspace anterior.
- Valores monetarios como `double` podem gerar arredondamento incorreto.
- Categorias/transacoes sistemicas precisam de protecao visual para evitar acoes bloqueadas pela API.
- Dashboard deve usar endpoint consolidador para evitar carga excessiva no mobile.
