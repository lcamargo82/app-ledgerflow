# LedgerFlow Docs

Esta pasta guarda a documentacao viva do app Flutter LedgerFlow.

## Estrutura

- `PRD.md`: visao de produto, publico, escopo e prioridades.
- `SDD.md`: desenho tecnico do app Flutter, arquitetura, bibliotecas recomendadas e integracao com a API.
- `design/design-system.md`: sistema visual extraido do ZIP de referencia.
- `features/<feature>/spec.md`: especificacao funcional e tecnica de cada feature.
- `features/<feature>/sprint.md`: backlog de sprint por feature.

## Convencao Para Novas Features

Para cada nova area do app, crie:

```text
docs/features/nome-da-feature/spec.md
docs/features/nome-da-feature/sprint.md
```

O `spec.md` deve explicar o problema, fluxos, modelos, endpoints, estados de UI, validacoes e criterios de aceite.

O `sprint.md` deve quebrar a entrega em tarefas pequenas, preferencialmente organizadas em UX/UI, dominio, dados/API, testes e criterios de pronto.

## Contexto Atual

- App mobile Flutter em inicio de projeto.
- API local informada: `http://localhost:3020`.
- API encontrada no ambiente: `/Users/leandro/Documents/Projetos/Node/api-ledgerflow`.
- API atual: NestJS + Prisma + PostgreSQL, com cadastro, login, refresh token, logout, recuperacao de senha e perfil.
- Referencia visual: `/Users/leandro/Downloads/stitch_ledgerflow_personal_finance_ui.zip`.

