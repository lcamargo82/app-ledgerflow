# Product Requirements Document (PRD)

## Visao Geral

LedgerFlow sera um app Flutter de gestao financeira pessoal com suporte a isolamento por workspace. O objetivo e ajudar o usuario a entender para onde o dinheiro esta indo, organizar contas, registrar movimentacoes e visualizar seu fluxo financeiro com clareza.

O produto comeca com foco em uso pessoal, mas a API ja suporta workspaces `PERSONAL` e `BUSINESS`, permitindo evoluir para uso misto sem reescrever o app.

## Objetivos

- Permitir cadastro, login, logout, recuperacao de senha e edicao de perfil.
- Identificar se o usuario precisa de onboarding financeiro pelo retorno de `GET /auth/me`.
- Criar workspaces iniciais por escolha: pessoal, negocio ou ambos.
- Permitir alternar workspace ativo sem misturar dados financeiros.
- Registrar contas/cofres com instituicao, tipo, cor, icone, saldo inicial e opcao de incluir no saldo total.
- Registrar receitas e despesas manuais por conta, categoria, data, valor e descricao.
- Listar extrato paginado com filtros e agrupamento visual por dia.
- Mostrar dashboard com saldo consolidado, contas ativas, despesas por categoria e indicadores mensais.
- Exibir relatorios mensais simples e confiaveis.
- Proteger tokens e preferencias sensiveis em armazenamento seguro do dispositivo.

## Publico

Pessoas que querem controlar financas pessoais sem planilhas complexas, com foco em:

- acompanhamento diario de despesas;
- visao consolidada de saldos;
- categorizacao facil;
- relatorios visuais;
- separacao entre financas pessoais e eventual organizacao/negocio.

## Escopo MVP

1. Autenticacao e perfil.
2. Onboarding financeiro.
3. Workspaces e workspace ativo.
4. Dashboard financeiro inicial.
5. Contas/cofres e instituicoes.
6. Categorias.
7. Transacoes: receita e despesa.
8. Relatorios mensais basicos.
9. Configuracoes: moeda, tema, biometria e logout.

## Fora do Escopo Inicial

- Open finance/integracao bancaria automatica.
- Multiusuario avancado, convites ou permissoes editaveis no app.
- Investimentos avancados.
- Importacao automatica de extratos.
- IA para categorizacao automatica.
- Versao web completa.
- Transferencia real entre contas, salvo se a API expuser contrato dedicado.

## Jornadas Principais

### Primeiro acesso

1. Usuario abre o app.
2. App procura tokens no storage seguro.
3. Sem token, mostra login.
4. Com token, chama `GET /auth/me`.
5. Se `onboardingRequired = true`, mostra onboarding financeiro.
6. Se ha `currentWorkspace`, carrega dashboard do workspace.

### Onboarding

1. Usuario escolhe como quer usar o LedgerFlow: pessoal, negocio ou ambos.
2. App envia `POST /workspaces/onboarding` com `choice`.
3. API cria workspaces e categorias padrao.
4. App salva workspace ativo e leva usuario para criacao da primeira conta.

### Registro de primeira conta

1. Usuario escolhe instituicao pelo catalogo de `GET /institutions`.
2. Preenche nome, tipo, cor, icone, saldo inicial e `includeInTotal`.
3. App envia `POST /workspaces/:workspaceId/accounts`.
4. API cria conta e, se houver saldo inicial, cria transacao genesis.
5. App atualiza dashboard e lista de contas.

### Lancamento de despesa ou receita

1. Usuario toca em novo lancamento.
2. Escolhe tipo `INCOME` ou `EXPENSE`.
3. Seleciona conta e categoria compativel.
4. Informa valor BRL, data e descricao.
5. App envia `POST /workspaces/:workspaceId/transactions`.
6. App invalida caches de dashboard, extrato, contas e relatorios.

## Telas Do MVP

- Splash/boot de sessao.
- Login com biometria.
- Cadastro.
- Recuperacao de senha.
- Onboarding financeiro.
- Criacao de primeira conta.
- Dashboard.
- Extrato/transacoes.
- Nova transacao.
- Detalhes da transacao.
- Minhas contas.
- Gerenciar categorias.
- Relatorios.
- Perfil/configuracoes.

## Principais Indicadores De Sucesso

- Usuario cadastra, faz onboarding e chega ao dashboard sem friccao.
- Usuario cria primeira conta em menos de 1 minuto.
- Usuario registra uma despesa em menos de 30 segundos.
- Dashboard comunica saldo, tendencia e ultimas movimentacoes sem exigir navegacao.
- Troca de workspace nunca mistura dados.
- Erros da API aparecem com mensagem compreensivel.

## Requisitos Nao Funcionais

- Seguranca: access token e refresh token em `flutter_secure_storage`.
- Performance: telas principais com loading/skeleton e requests consolidados quando possivel.
- Manutenibilidade: separacao entre UI, estado, dominio e infra/API.
- Acessibilidade: contraste alto no tema escuro, labels visiveis e areas de toque adequadas.
- Confiabilidade: refresh token automatico uma vez em `401`; logout local quando refresh falhar.
