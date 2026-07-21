# Plano: Transferencias E Colaboracao No App

## Validacao Da API

Base validada em `Node/api-ledgerflow`:

- Transferencias entre contas estao implementadas no backend.
- `TransactionType` agora aceita `INCOME`, `EXPENSE` e `TRANSFER`.
- `Transaction` possui `accountId` como conta origem e `destinationAccountId` como conta destino.
- `categoryId` nao e usado em transferencias.
- `POST /workspaces/:workspaceId/transactions` cria receita, despesa ou transferencia.
- `GET /workspaces/:workspaceId/transactions` aceita filtro `type=TRANSFER` e retorna `destinationAccount`.
- `PATCH /workspaces/:workspaceId/transactions/:transactionId` e `DELETE /workspaces/:workspaceId/transactions/:transactionId` suportam transferencias manuais.
- A API bloqueia transferencia para a mesma conta e transferencia com saldo insuficiente.
- Convites de workspace estao implementados com `WorkspaceInvitation`.
- Existem membros por workspace com roles `OWNER`, `ADMIN`, `EDITOR` e `VIEWER`.
- Endpoints de colaboracao disponiveis:
  - `GET /workspaces/:workspaceId/members`
  - `GET /workspaces/:workspaceId/invitations`
  - `POST /workspaces/:workspaceId/invitations`
  - `DELETE /workspaces/:workspaceId/invitations/:invitationId`
  - `PATCH /workspaces/:workspaceId/members/:memberId`
  - `DELETE /workspaces/:workspaceId/members/:memberId`
  - `POST /workspace-invitations/accept`
  - `POST /workspace-invitations/decline`
- Reenvio de convite aparece como pendente na documentacao da API.

## Estado Atual Do App

- O dominio Flutter de transacoes ainda conhece apenas `INCOME` e `EXPENSE`.
- O formulario de nova transacao ainda trata `Transferencia` como tipo nao suportado.
- `CreateTransactionRequest` sempre envia `categoryId`, o que nao serve para `TRANSFER`.
- O extrato ainda nao modela `destinationAccountId` nem `destinationAccount`.
- A tela de Perfil ainda nao possui area de membros/convites.
- Existe estado de workspace ativo, mas falta uma tela completa de gestao e troca de workspace.

## Decisoes De Produto

- Transferencia deve ser lancada no mesmo fluxo do botao `+`, mas com campos proprios.
- Para transferencia, a UI deve pedir:
  - conta origem;
  - conta destino;
  - valor;
  - descricao;
  - data.
- Categoria deve sumir no modo transferencia.
- Conta destino nao pode ser igual a origem.
- O app pode validar saldo localmente quando o saldo da conta estiver carregado, mas a API continua sendo a fonte final.
- Convites e membros devem ficar no Perfil, dentro de uma secao "Workspace" ou "Compartilhamento".
- Roles devem ser exibidas com texto simples:
  - `OWNER`: Proprietario
  - `ADMIN`: Administrador
  - `EDITOR`: Editor
  - `VIEWER`: Visualizador
- Usuarios `VIEWER` devem ver dados, mas nao devem conseguir criar contas, categorias ou transacoes.

## Sprint 1: Contrato De Transferencias No App

Objetivo: preparar o dominio Flutter para entender transferencias sem alterar visualmente todo o fluxo.

Tarefas:

- [ ] Adicionar `TransactionType.transfer`.
- [ ] Adicionar `destinationAccountId` em `LedgerTransaction`.
- [ ] Modelar `destinationAccount` resumida, reaproveitando ou criando `TransactionAccountSummary`.
- [ ] Ajustar `signedAmountCents` para transferencia.
- [ ] Atualizar parser de `TransactionPage`.
- [ ] Atualizar `CreateTransactionRequest` para aceitar `destinationAccountId` opcional e `categoryId` opcional.
- [ ] Para `TRANSFER`, enviar `destinationAccountId` e nao enviar `categoryId`.
- [ ] Adicionar testes de parsing para transacao `TRANSFER`.

Criterios de aceite:

- App parseia transacoes `TRANSFER` sem cair em `EXPENSE`.
- Payload de transferencia segue o contrato da API.
- Receitas e despesas continuam funcionando.

## Sprint 2: UI De Nova Transferencia

Objetivo: liberar o lancamento de transferencia pelo botao `+`.

Tarefas:

- [ ] Remover mensagem de tipo nao suportado para `Transferencia`.
- [ ] No modo transferencia, trocar campo `Categoria` por `Conta destino`.
- [ ] Filtrar conta destino para nao permitir a mesma conta origem.
- [ ] Atualizar `canSubmit` para regras por tipo.
- [ ] Ajustar labels: `Conta origem`, `Conta destino`, `Salvar transferencia`.
- [ ] Exibir erro amigavel para saldo insuficiente retornado pela API.
- [ ] Recarregar dashboard, extrato e contas apos salvar.
- [ ] Testar fluxo com duas contas.

Criterios de aceite:

- Usuario cria transferencia valida.
- Transferencia entre mesma conta e bloqueada antes do submit.
- Saldo insuficiente mostra feedback compreensivel.
- Dashboard e contas refletem a transferencia apos salvar.

## Sprint 3: Extrato E Detalhe De Transferencias

Objetivo: representar transferencias com clareza nas listagens.

Tarefas:

- [ ] Ajustar cards do extrato para mostrar `Origem -> Destino`.
- [ ] Usar icone de troca para transferencia.
- [ ] Evitar classificar transferencia como receita ou despesa nos totais visuais locais.
- [ ] Adicionar filtro por tipo incluindo `Transferencia`.
- [ ] Criar detalhe ou bottom sheet de transacao com campos de origem/destino.
- [ ] Garantir que transacoes sistemicas continuem protegidas.

Criterios de aceite:

- Transferencias aparecem distinguiveis no extrato.
- Filtro `TRANSFER` funciona.
- Origem e destino aparecem no detalhe.

## Sprint 4: Contrato De Colaboracao

Objetivo: criar camada de dados Flutter para membros e convites.

Tarefas:

- [ ] Criar modelos `WorkspaceMember`, `WorkspaceInvitation`, `WorkspaceRole` e `WorkspaceInvitationStatus`.
- [ ] Criar `WorkspaceMembersApi` ou expandir `WorkspacesApi`.
- [ ] Criar repository para:
  - listar membros;
  - listar convites;
  - criar convite;
  - cancelar convite;
  - alterar role;
  - remover membro;
  - aceitar convite;
  - recusar convite.
- [ ] Criar controller/provider para estado de compartilhamento.
- [ ] Mapear permissoes locais por role.
- [ ] Adicionar testes de parser e repository com mocks.

Criterios de aceite:

- App consome membros e convites do workspace ativo.
- Erros de permissao sao tratados.
- Estado recarrega ao trocar workspace.

## Sprint 5: Tela De Membros E Convites

Objetivo: permitir ao proprietario/admin gerenciar quem acessa o workspace.

Tarefas:

- [ ] Adicionar item "Compartilhamento" ou "Membros" no Perfil.
- [ ] Criar tela/listagem de membros.
- [ ] Mostrar nome, email, role e data de entrada.
- [ ] Criar formulario de convite com email e role.
- [ ] Listar convites pendentes com email, role, status e expiracao.
- [ ] Permitir cancelar convite pendente.
- [ ] Permitir alterar role de membro conforme permissao.
- [ ] Permitir remover membro conforme permissao.
- [ ] Proteger ultimo `OWNER` com mensagem clara.

Criterios de aceite:

- Usuario autorizado convida outro usuario.
- Convite aparece como pendente.
- Membro pode ter role alterada ou ser removido conforme regras da API.
- Usuario sem permissao ve tela em modo leitura.

## Sprint 6: Aceite De Convite No Mobile

Objetivo: permitir que o convidado entre em um workspace.

Tarefas:

- [ ] Definir estrategia de deep link para `workspace-invitations/accept?token=...`.
- [ ] Criar tela de convite recebido.
- [ ] Se usuario nao estiver autenticado, direcionar para login/cadastro e preservar token.
- [ ] Apos login/cadastro, chamar `POST /workspace-invitations/accept`.
- [ ] Implementar recusa com `POST /workspace-invitations/decline`.
- [ ] Apos aceite, salvar workspace ativo do convite e recarregar dados.
- [ ] Tratar token expirado, ja aceito, recusado ou email divergente.

Criterios de aceite:

- Convidado autenticado aceita convite e entra no workspace.
- Convidado nao autenticado consegue autenticar e continuar o aceite.
- Workspace aceito fica disponivel na lista de workspaces.

## Sprint 7: Permissoes E Polimento

Objetivo: deixar colaboracao segura e previsivel no app.

Tarefas:

- [ ] Bloquear acoes de escrita para `VIEWER`.
- [ ] Ocultar ou desabilitar botoes de criar/editar/remover conforme role.
- [ ] Adicionar indicador do workspace ativo no Dashboard e Perfil.
- [ ] Implementar troca de workspace por bottom sheet.
- [ ] Invalidar dashboard, contas, categorias, transacoes e relatorios ao trocar workspace.
- [ ] Revisar mensagens de erro de API para permissao, saldo insuficiente e convite invalido.
- [ ] Adicionar testes de controller para troca de workspace e permissoes.

Criterios de aceite:

- Usuario so ve acoes que pode executar.
- Troca de workspace nao mistura dados.
- Fluxos principais ficam coerentes para dono, editor e visualizador.

## Ordem Recomendada

1. Transferencia contrato.
2. Transferencia UI.
3. Extrato e detalhe de transferencias.
4. Contrato de colaboracao.
5. Tela de membros e convites.
6. Aceite de convite por link/token.
7. Permissoes, seletor de workspace e polimento.

## Riscos

- Deep link de convite exige configuracao Android/iOS e ambiente de producao.
- Reenvio de convite ainda nao esta implementado na API, entao nao deve aparecer como acao ativa no app.
- Permissoes locais precisam refletir a API, mas a API continua sendo a fonte de verdade.
- Transferencias impactam saldo de duas contas; qualquer cache local precisa ser recarregado apos mutacao.
