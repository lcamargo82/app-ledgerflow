# Product Requirements Document (PRD)

## Visao Geral

LedgerFlow sera um app Flutter de gestao financeira pessoal, inspirado em experiencias como Mobills, Despezzas, Organizze e apps similares. O objetivo e ajudar o usuario a entender para onde o dinheiro esta indo, organizar contas, registrar transacoes e visualizar seu fluxo financeiro com clareza.

## Objetivos

- Permitir cadastro, login, logout, recuperacao de senha e edicao de perfil.
- Registrar receitas, despesas e transferencias entre contas.
- Organizar transacoes por conta, categoria, data e tipo.
- Mostrar dashboard com saldo total, evolucao mensal e transacoes recentes.
- Exibir relatorios simples e confiaveis de gastos, receitas, categorias e orcamentos.
- Oferecer uma experiencia mobile rapida, escura, clara e confortavel para consulta diaria.

## Publico

Pessoas que querem controlar finanças pessoais sem planilhas complexas, com foco em:

- acompanhamento diario de despesas;
- visao consolidada de saldos;
- categorizacao facil;
- relatorios visuais;
- controle de orcamento mensal.

## Escopo MVP

1. Autenticacao e Perfil
2. Dashboard financeiro inicial
3. Contas/carteiras
4. Categorias
5. Transacoes: receita, despesa e transferencia
6. Relatorios mensais basicos
7. Configuracoes: moeda, tema, biometria e logout

## Fora do Escopo Inicial

- Open finance/integracao bancaria automatica.
- Multiusuario, contas compartilhadas ou familia.
- Investimentos avancados.
- Importacao automatica de extratos.
- IA para categorizacao automatica.
- Versao web completa.

## Telas Observadas No Design

O ZIP de referencia contem telas para:

- Login com biometria
- Cadastro
- Criacao de perfil
- Recuperacao de senha
- Dashboard
- Relatorios
- Detalhes da transacao
- Nova transacao
- Transferencia entre contas
- Minhas contas
- Gerenciar categorias
- Configuracoes e perfil

## Principais Indicadores De Sucesso

- Usuario consegue cadastrar, logar e acessar o dashboard sem friccao.
- Usuario registra uma despesa em menos de 30 segundos.
- Dashboard comunica saldo, tendencia e ultimas transacoes sem precisar navegar.
- Relatorios ajudam a identificar categorias de maior gasto no mes.
- Tokens e dados sensiveis ficam protegidos no dispositivo.

## Requisitos Nao Funcionais

- Segurança: access token e refresh token devem ser armazenados com armazenamento seguro do dispositivo.
- Performance: telas principais devem carregar com skeleton/loading claro e evitar jank em animacoes.
- Offline gradual: MVP pode depender da API, mas a arquitetura deve permitir cache local depois.
- Acessibilidade: contraste alto no tema escuro, labels de campos e botoes, tamanhos de toque adequados.
- Manutenibilidade: separacao entre UI, estado, dominio e infra/API.

