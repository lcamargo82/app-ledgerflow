enum TransactionEntryType {
  income('Receita'),
  expense('Despesa'),
  transfer('Transferencia'),
  cardExpense('Despesa cartao');

  const TransactionEntryType(this.label);

  final String label;
}
