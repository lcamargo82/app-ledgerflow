# Roadmap De Implementacao

Este roadmap revisa o plano anexado em `/Users/leandro/Downloads/ledgerflow_flutter_spec.md` e organiza a execucao em sprints incrementais.

## Principios

- Implementar sempre em branch `feature/...` a partir de `develop`.
- Manter uma entrega navegavel a cada sprint.
- Integrar primeiro os fluxos que desbloqueiam dados reais: auth, onboarding e workspace.
- Evitar mocks depois que o contrato da API estiver conectado.
- Toda mutacao financeira deve invalidar dashboard e relatorios.

## Sprint 0: Fundacao Mobile

Status: parcialmente iniciada.

Escopo:

- Tema Precision Dark.
- Roteamento com `go_router`.
- Estado com Riverpod.
- Estrutura `lib/src`.
- Telas iniciais navegaveis.
- Base de widgets compartilhados.

Arquivos relacionados:

- `docs/SDD.md`
- `docs/design/design-system.md`

## Sprint 1: Auth Real E Sessao

Escopo:

- Dio.
- Storage seguro.
- Login/cadastro/refresh/logout.
- Boot de sessao.
- Redirect por `GET /auth/me`.

Arquivo:

- `docs/features/auth/sprint.md`

## Sprint 2: Onboarding E Workspace Ativo

Escopo:

- Onboarding `PERSONAL`, `BUSINESS`, `BOTH`.
- Criacao de workspaces iniciais.
- Workspace ativo persistido.
- Troca de workspace e invalidacao de cache.

Arquivos:

- `docs/features/onboarding/sprint.md`
- `docs/features/workspaces/sprint.md`

## Sprint 3: Contas E Instituicoes

Escopo:

- Catalogo de instituicoes.
- Primeira conta.
- Lista de contas.
- Criar/editar/arquivar conta.
- Saldo inicial com transacao genesis criada pela API.

Arquivo:

- `docs/features/accounts/sprint.md`

## Sprint 4: Categorias

Escopo:

- Listar categorias por tipo.
- Criar/editar/remover/arquivar.
- Protecao de categorias sistemicas.
- Mapper central de icones e cores.

Arquivo:

- `docs/features/categories/sprint.md`

## Sprint 5: Transacoes

Escopo:

- Extrato paginado.
- Agrupamento por dia no Flutter.
- Criar receita/despesa.
- Detalhe/edicao/remocao de transacao manual.
- Protecao de `INITIAL_BALANCE`.

Arquivo:

- `docs/features/transactions/sprint.md`

## Sprint 6: Dashboard Real

Escopo:

- `GET /workspaces/:workspaceId/dashboard/summary`.
- Saldos consolidados.
- Donut de despesas.
- Contas ativas.
- Empty/error/retry.

Arquivo:

- `docs/features/dashboard/sprint.md`

## Sprint 7: Relatorios

Escopo:

- `monthly-summary`.
- Comparativo mensal.
- Ranking de categorias.
- Periodo mes/ano.

Arquivo:

- `docs/features/reports/sprint.md`

## Sprint 8: Perfil, Configuracoes E Polimento

Escopo:

- Perfil real.
- Edicao de dados.
- Troca de senha.
- Biometria local.
- Preferencias locais.
- Polimento de loading, empty states, animacoes e acessibilidade.

Arquivo:

- `docs/features/settings/sprint.md`

## Decisoes Confirmadas

- Usar Material 3 com tema escuro como padrao.
- Usar `Icons` do Material no MVP, com mapper por string para dados vindos da API.
- Usar `fl_chart` para graficos.
- Usar `go_router` e `flutter_riverpod`.
- Usar `dio` e `flutter_secure_storage` na integracao real.
- Usar endpoint de dashboard consolidado em vez de baixar transacoes para montar dashboard.

## Decisoes Pendentes

- Confirmar se transferencia entre contas entrara no MVP ou ficara para quando a API tiver endpoint dedicado.
- Definir estrategia de cache offline depois do MVP.
- Definir se tema claro sera implementado agora ou apenas preparado.
