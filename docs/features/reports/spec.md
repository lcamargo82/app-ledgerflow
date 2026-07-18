# Feature Spec: Relatorios

## Objetivo

Dar ao usuario uma visao clara dos gastos, receitas, orcamentos e tendencias do mes.

## Relatorios MVP

- Receitas vs despesas no mes.
- Despesas por categoria.
- Orcamento mensal por categoria.
- Evolucao de saldo.
- Maiores transacoes do periodo.

## Visualizacoes

### Donut/Pie

Uso:

- despesas por categoria.

Dados:

- categoria;
- valor;
- percentual;
- cor.

### Barras

Uso:

- receitas vs despesas por mes;
- comparacao entre meses.

### Linha

Uso:

- evolucao de saldo ao longo do tempo.

### Progress Bar

Uso:

- percentual de uso de orcamento por categoria.

Estados:

- ate 80%: neutro/ciano;
- 80% a 100%: atencao;
- acima de 100%: erro/coral.

## Filtros

MVP:

- mes atual;
- trocar mes anterior/proximo;
- todas as contas.

Futuro:

- periodo customizado;
- por conta;
- por categoria;
- por tipo.

## Criterios De Aceite

- Usuario entende rapidamente se gastou mais do que recebeu.
- Usuario identifica as categorias mais caras.
- Usuario ve orcamentos estourados.
- Graficos possuem legenda e valores legiveis.
- Tela funciona bem sem dados, com empty state claro.

