# Spec: Nucleo Financeiro

Esta feature agora funciona como indice historico do nucleo financeiro. As specs detalhadas foram separadas em:

- `features/workspaces`
- `features/accounts`
- `features/categories`
- `features/transactions`
- `features/dashboard`
- `features/reports`

## Principios

- Toda consulta financeira exige `workspaceId` ativo.
- Contas, categorias e transacoes sao escopadas por workspace.
- Mutacoes financeiras invalidam dashboard e relatorios.
- Valores monetarios devem ser tratados com precisao, preferencialmente em centavos.
