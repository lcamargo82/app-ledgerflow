import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LedgerScaffold(
      title: 'Transações',
      subtitle: 'Registre receitas, despesas e transferencias.',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filled(
            tooltip: 'Nova transação',
            onPressed: () => _openNewTransaction(context),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
      children: [
        const _TransactionSummary(),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Este mes',
          actionLabel: 'Nova',
          onAction: () => _openNewTransaction(context),
        ),
        const SizedBox(height: 8),
        const _TransactionRow(
          title: 'Aluguel',
          category: 'Moradia',
          value: '- R\$ 1.800,00',
          color: AppColors.error,
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 8),
        const _TransactionRow(
          title: 'Projeto freelance',
          category: 'Receita',
          value: '+ R\$ 1.450,00',
          color: AppColors.emerald,
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 8),
        const _TransactionRow(
          title: 'Transferencia reserva',
          category: 'Carteiras',
          value: 'R\$ 600,00',
          color: AppColors.tertiary,
          icon: Icons.sync_alt,
        ),
      ],
    );
  }

  static void _openNewTransaction(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _NewTransactionSheet(),
    );
  }
}

class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricCard(
            label: 'Receitas',
            value: 'R\$ 7.650',
            color: AppColors.emerald,
            icon: Icons.trending_up,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Despesas',
            value: 'R\$ 4.220',
            color: AppColors.error,
            icon: Icons.trending_down,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.category,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String category;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(category, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NewTransactionSheet extends StatelessWidget {
  const _NewTransactionSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nova transação',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'income', label: Text('Receita')),
              ButtonSegment(value: 'expense', label: Text('Despesa')),
              ButtonSegment(value: 'transfer', label: Text('Transferir')),
            ],
            selected: {'expense'},
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Valor',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Descricao',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Categoria',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text('Salvar transação'),
          ),
        ],
      ),
    );
  }
}
