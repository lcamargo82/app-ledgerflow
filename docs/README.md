# LedgerFlow Mobile Docs

Documentacao viva do app Flutter LedgerFlow.

## Contexto

- App mobile Flutter para gestao financeira pessoal e, futuramente, pequenos negocios.
- Branch de implementacao inicial: `feature/primeiras-telas`.
- API de producao: `https://api-appledgerflow.lcamargo.dev.br`.
- API local de desenvolvimento: `http://localhost:3020`.
- API para Android Emulator: `http://10.0.2.2:3020`.
- Codigo da API para consulta: `/Users/leandro/Documents/Projetos/Node/api-ledgerflow`.
- Referencia visual atual: `/Users/leandro/Downloads/stitch_ledgerflow_personal_finance_ui (1).zip`.
- Plano mobile anexado: `/Users/leandro/Downloads/ledgerflow_flutter_spec.md`.

## Estrutura

- `PRD.md`: visao de produto, escopo, jornadas e prioridades.
- `SDD.md`: desenho tecnico Flutter, arquitetura, estado, rede, seguranca e integracao.
- `api/endpoints.md`: contrato resumido da API consumida pelo app.
- `implementation-roadmap.md`: ordem revisada das sprints de implementacao.
- `design/design-system.md`: sistema visual Precision Dark.
- `features/<feature>/spec.md`: especificacao funcional e tecnica da feature.
- `features/<feature>/sprint.md`: backlog de implementacao da feature.

## Features Documentadas

- `auth`: login, cadastro, refresh token, logout, recuperacao de senha e perfil de usuario.
- `onboarding`: escolha de uso pessoal/negocio/ambos e criacao dos workspaces iniciais.
- `workspaces`: selecao, troca e isolamento de dados por workspace.
- `accounts`: contas/cofres, instituicoes e saldo inicial com transacao genesis.
- `categories`: categorias de receitas/despesas e protecao de categorias sistemicas.
- `transactions`: receitas, despesas, extrato paginado e protecao de transacoes sistemicas.
- `dashboard`: resumo financeiro consolidado e graficos principais.
- `reports`: relatorios mensais e consolidadores.
- `settings`: perfil, preferencias, biometria, tema e logout.

## Convencao Para Novas Features

Para cada nova area do app, crie:

```text
docs/features/nome-da-feature/spec.md
docs/features/nome-da-feature/sprint.md
```

O `spec.md` deve explicar problema, fluxos, modelos, endpoints, estados de UI, validacoes e criterios de aceite.

O `sprint.md` deve quebrar a entrega em tarefas pequenas, organizadas em UX/UI, dominio, dados/API, testes e definicao de pronto.

## Ordem Recomendada De Implementacao

1. Fundacao tecnica: config, tema, router, Dio, storage seguro e padrao de erros.
2. Auth real e sessao persistida.
3. Onboarding financeiro e selecao de workspace.
4. Contas e instituicoes.
5. Categorias.
6. Transacoes e extrato.
7. Dashboard real.
8. Relatorios.
9. Configuracoes, perfil e polimento.
