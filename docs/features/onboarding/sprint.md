# Sprint: Onboarding Financeiro

## Objetivo

Implementar fluxo de onboarding baseado em workspace.

## Tarefas

- [ ] Criar feature `onboarding`.
- [ ] Criar modelo `OnboardingChoice`.
- [ ] Criar `OnboardingApi` usando `POST /workspaces/onboarding`.
- [ ] Criar `OnboardingRepository`.
- [ ] Criar `OnboardingController`.
- [ ] Criar tela de escolha pessoal/negocio/ambos.
- [ ] Atualizar redirect do router para `/onboarding`.
- [ ] Salvar `currentWorkspace` apos sucesso.
- [ ] Redirecionar para primeira conta ou dashboard.
- [ ] Criar teste de controller para sucesso e erro.
- [ ] Criar widget test da tela.

## Definicao De Pronto

- Usuario com `onboardingRequired = true` e bloqueado fora do shell.
- Onboarding cria workspace real.
- App invalida/recarrega `GET /auth/me` apos onboarding.
