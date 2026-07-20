import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/money.dart';
import '../../../core/icons/ledger_icon_mapper.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';
import '../domain/dashboard_summary.dart';
import 'controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardControllerProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dashboardControllerProvider);
    final summary = controller.summary;

    return LedgerScaffold(
      title: 'Olá!',
      subtitle: 'Aqui esta o resumo do seu fluxo financeiro neste mes.',
      children: [
        if (controller.isLoading)
          const _LoadingState()
        else if (controller.errorMessage != null)
          _ErrorState(
            message: controller.errorMessage!,
            onRetry: () => ref.read(dashboardControllerProvider).load(),
          )
        else if (summary == null || !summary.hasAccounts)
          _EmptyDashboardCard(
            onCreateAccount: () => context.go('/settings/accounts'),
          )
        else ...[
          _BalanceCard(summary: summary),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/transactions'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Receita'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/transactions'),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Despesa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CategoryChartCard(expenses: summary.expensesByCategory),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Contas ativas',
            actionLabel: 'Gerenciar',
            onAction: () => context.go('/settings/accounts'),
          ),
          const SizedBox(height: 8),
          ...summary.accounts.map(
            (account) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AccountTile(account: account),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go('/transactions'),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Ver extrato completo'),
          ),
        ],
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      color: AppColors.surfaceHigh,
      borderColor: AppColors.emerald.withValues(alpha: .5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO EM CONTAS',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            Money.formatCents(summary.totalIncludedCents),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          if (summary.hasExcludedAmount) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${Money.formatCents(summary.totalOverallCents)} no total geral',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceMetric(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Saldo atual',
                value: Money.formatCents(summary.currentBalanceCents),
              ),
              const SizedBox(width: 12),
              _BalanceMetric(
                icon: Icons.done_all_outlined,
                label: 'Incluido',
                value: Money.formatCents(summary.totalIncludedCents),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChartCard extends StatelessWidget {
  const _CategoryChartCard({required this.expenses});

  final List<ExpenseByCategory> expenses;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Despesas por categoria',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          if (expenses.isEmpty)
            const _EmptyExpensesState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 420;
                final chart = SizedBox(
                  height: 168,
                  width: 168,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 44,
                      sectionsSpace: 2,
                      sections: expenses
                          .map(
                            (expense) => PieChartSectionData(
                              value: expense.amountCents.abs().toDouble(),
                              color:
                                  _colorFromHex(expense.color) ??
                                  AppColors.primaryContainer,
                              radius: 28,
                              showTitle: false,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
                final legend = Column(
                  children: expenses
                      .map((expense) => _LegendRow(expense: expense))
                      .toList(),
                );

                if (isWide) {
                  return Row(
                    children: [
                      chart,
                      const SizedBox(width: 24),
                      Expanded(child: legend),
                    ],
                  );
                }

                return Column(
                  children: [
                    Center(child: chart),
                    const SizedBox(height: 16),
                    legend,
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyExpensesState extends StatelessWidget {
  const _EmptyExpensesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.donut_large_outlined,
            size: 36,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Sem despesas neste mes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'As categorias aparecem aqui quando houver lancamentos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.expense});

  final ExpenseByCategory expense;

  @override
  Widget build(BuildContext context) {
    final percent = expense.percent > 0
        ? '${expense.percent.toStringAsFixed(0)}%'
        : Money.formatCents(expense.amountCents);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _colorFromHex(expense.color) ?? AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            LedgerIconMapper.fromKey(expense.icon),
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(expense.name)),
          Text(percent),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final DashboardAccount account;

  @override
  Widget build(BuildContext context) {
    final balanceColor = account.balanceCents < 0
        ? AppColors.error
        : AppColors.emerald;

    return LfCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                _colorFromHex(account.color) ?? AppColors.surfaceHigh,
            foregroundColor: Colors.white,
            child: Icon(LedgerIconMapper.fromKey(account.icon)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  _accountTypeLabel(account.type),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.formatCents(account.balanceCents),
                style: TextStyle(
                  color: balanceColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!account.includeInTotal)
                Text(
                  'Fora do total',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboardCard extends StatelessWidget {
  const _EmptyDashboardCard({required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma conta ativa',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre uma conta para ver saldo, despesas e resumo do mes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateAccount,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar conta'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

String _accountTypeLabel(String value) {
  return switch (value) {
    'CHECKING' => 'Conta corrente',
    'SAVINGS' => 'Poupanca',
    'WALLET' => 'Carteira',
    'INVESTMENT' => 'Investimento',
    'BENEFITS' => 'Beneficios',
    'CREDIT_CARD' => 'Cartao de credito',
    _ => 'Outra',
  };
}

Color? _colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return null;
  }

  return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
}
