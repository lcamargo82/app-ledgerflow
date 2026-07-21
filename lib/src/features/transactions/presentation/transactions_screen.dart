import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/money.dart';
import '../../../core/icons/ledger_icon_mapper.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../accounts/domain/account.dart';
import '../../categories/domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_entry_type.dart';
import 'controllers/transactions_controller.dart';

void openNewTransactionSheet(
  BuildContext context, {
  TransactionEntryType initialType = TransactionEntryType.expense,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (context) => _NewTransactionSheet(initialType: initialType),
  );
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transactionsControllerProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(transactionsControllerProvider);

    return LedgerScaffold(
      title: 'Transações',
      subtitle: 'Registre receitas e despesas do workspace ativo.',
      children: [
        _TransactionSummary(summary: controller.summary),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Este mes',
          actionLabel: 'Nova',
          onAction: () => openNewTransactionSheet(context),
        ),
        const SizedBox(height: 8),
        if (controller.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          )
        else if (controller.errorMessage != null)
          _ErrorState(
            message: controller.errorMessage!,
            onRetry: () => ref.read(transactionsControllerProvider).load(),
          )
        else if (controller.transactions.isEmpty)
          _EmptyTransactionsCard(
            onCreate: () => openNewTransactionSheet(context),
          )
        else
          ..._groupTransactions(controller.transactions).entries.map(
            (entry) => _TransactionDayGroup(
              label: entry.key,
              transactions: entry.value,
              controller: controller,
            ),
          ),
      ],
    );
  }
}

class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary({required this.summary});

  final MonthlySummary? summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Receitas',
            value: Money.formatCents(summary?.totalIncomesCents ?? 0),
            color: AppColors.emerald,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Despesas',
            value: Money.formatCents(summary?.totalExpensesCents ?? 0),
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

class _TransactionDayGroup extends StatelessWidget {
  const _TransactionDayGroup({
    required this.label,
    required this.transactions,
    required this.controller,
  });

  final String label;
  final List<LedgerTransaction> transactions;
  final TransactionsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransactionRow(
                transaction: transaction,
                account: controller.accountById(transaction.accountId),
                category: transaction.categoryId == null
                    ? null
                    : controller.categoryById(transaction.categoryId!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.account,
    required this.category,
  });

  final LedgerTransaction transaction;
  final Account? account;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final amountColor = switch (transaction.type) {
      TransactionType.expense => AppColors.error,
      TransactionType.income => AppColors.emerald,
      TransactionType.transfer => AppColors.primary,
    };
    final icon = transaction.isSystemGenerated
        ? Icons.lock_outline
        : transaction.type == TransactionType.transfer
        ? Icons.swap_horiz
        : LedgerIconMapper.fromKey(category?.icon);

    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: amountColor,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    if (category != null) category!.name,
                    if (account != null) account!.name,
                    if (transaction.isSystemGenerated) 'Saldo inicial',
                  ].join(' • '),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Text(
            Money.formatCents(transaction.signedAmountCents),
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 44,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transação ainda',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Registre sua primeira receita ou despesa para montar seu fluxo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar transação'),
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

class _NewTransactionSheet extends ConsumerStatefulWidget {
  const _NewTransactionSheet({required this.initialType});

  final TransactionEntryType initialType;

  @override
  ConsumerState<_NewTransactionSheet> createState() =>
      _NewTransactionSheetState();
}

class _NewTransactionSheetState extends ConsumerState<_NewTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TransactionEntryType _entryType = widget.initialType;
  String? _accountId;
  String? _categoryId;
  DateTime _occurredAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transactionsControllerProvider).load());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(transactionsControllerProvider);
    final transactionType = _transactionTypeFor(_entryType);
    final categories = transactionType == null
        ? const <Category>[]
        : controller.categoriesFor(transactionType);
    final accountValue =
        controller.accounts.any((account) => account.id == _accountId)
        ? _accountId
        : null;
    final categoryValue =
        categories.any((category) => category.id == _categoryId)
        ? _categoryId
        : null;
    final unsupported = transactionType == null;
    final canSubmit =
        !controller.isLoading &&
        !controller.isSaving &&
        controller.accounts.isNotEmpty &&
        categories.isNotEmpty &&
        accountValue != null &&
        categoryValue != null;
    final title = switch (_entryType) {
      TransactionEntryType.income => 'Nova receita',
      TransactionEntryType.expense => 'Nova despesa',
      TransactionEntryType.transfer => 'Nova transferencia',
      TransactionEntryType.cardExpense => 'Despesa no cartao',
    };

    return FractionallySizedBox(
      heightFactor: .9,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<TransactionEntryType>(
                        segments: const [
                          ButtonSegment(
                            value: TransactionEntryType.income,
                            label: Text('Receita'),
                          ),
                          ButtonSegment(
                            value: TransactionEntryType.expense,
                            label: Text('Despesa'),
                          ),
                          ButtonSegment(
                            value: TransactionEntryType.transfer,
                            label: Text('Transferir'),
                          ),
                        ],
                        selected: {
                          _entryType == TransactionEntryType.cardExpense
                              ? TransactionEntryType.expense
                              : _entryType,
                        },
                        onSelectionChanged: (selected) {
                          setState(() {
                            _entryType = selected.first;
                            _categoryId = null;
                          });
                        },
                      ),
                      if (unsupported) ...[
                        const SizedBox(height: 16),
                        const LfCard(
                          child: Text(
                            'Este tipo de lancamento sera ativado quando a API expor o contrato dedicado.',
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        if (controller.isLoading)
                          const LfCard(
                            child: Row(
                              children: [
                                SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Carregando contas e categorias...',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (controller.accounts.isEmpty)
                          const LfCard(
                            child: Text(
                              'Cadastre uma conta antes de criar transacoes.',
                            ),
                          )
                        else if (categories.isEmpty)
                          LfCard(
                            child: Text(
                              'Cadastre uma categoria de ${transactionType.label.toLowerCase()} antes de criar este lancamento.',
                            ),
                          ),
                        if (controller.isLoading ||
                            controller.accounts.isEmpty ||
                            categories.isEmpty)
                          const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: accountValue,
                          dropdownColor: AppColors.surfaceHighest,
                          style: const TextStyle(color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            labelText: 'Conta',
                            prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined,
                            ),
                          ),
                          validator: (value) =>
                              value == null ? 'Escolha uma conta.' : null,
                          items: controller.accounts
                              .map(
                                (account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(account.name),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isLoading
                              ? null
                              : (value) => setState(() => _accountId = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: categoryValue,
                          dropdownColor: AppColors.surfaceHighest,
                          style: const TextStyle(color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (value) =>
                              value == null ? 'Escolha uma categoria.' : null,
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: controller.isLoading
                              ? null
                              : (value) => setState(() => _categoryId = value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: _requiredAmount,
                          decoration: const InputDecoration(
                            labelText: 'Valor',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          validator: _requiredDescription,
                          decoration: const InputDecoration(
                            labelText: 'Descricao',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_dateLabel(_occurredAt)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!unsupported) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: canSubmit ? _submit : null,
                  icon: controller.isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Salvar transação'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TransactionType? _transactionTypeFor(TransactionEntryType type) {
    return switch (type) {
      TransactionEntryType.income => TransactionType.income,
      TransactionEntryType.expense ||
      TransactionEntryType.cardExpense => TransactionType.expense,
      TransactionEntryType.transfer => null,
    };
  }

  String? _requiredAmount(String? value) {
    if (Money.parseInputToCents(value ?? '') <= 0) {
      return 'Informe um valor maior que zero.';
    }

    return null;
  }

  String? _requiredDescription(String? value) {
    if ((value?.trim() ?? '').length < 2) {
      return 'Informe uma descricao.';
    }

    return null;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => _occurredAt = selected);
    }
  }

  Future<void> _submit() async {
    final type = _transactionTypeFor(_entryType);

    if (type == null || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final request = CreateTransactionRequest(
      accountId: _accountId!,
      categoryId: _categoryId!,
      type: type,
      amountCents: Money.parseInputToCents(_amountController.text),
      occurredAt: _occurredAt,
      description: _descriptionController.text.trim(),
    );
    final success = await ref
        .read(transactionsControllerProvider)
        .create(request);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(transactionsControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel criar a transacao.')),
    );
  }
}

Map<String, List<LedgerTransaction>> _groupTransactions(
  List<LedgerTransaction> transactions,
) {
  final grouped = <String, List<LedgerTransaction>>{};

  for (final transaction in transactions) {
    final label = _dateLabel(transaction.occurredAt);
    grouped.putIfAbsent(label, () => []).add(transaction);
  }

  return grouped;
}

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  final normalizedNow = DateTime(now.year, now.month, now.day);
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final difference = normalizedNow.difference(normalizedDate).inDays;

  if (difference == 0) {
    return 'Hoje';
  }

  if (difference == 1) {
    return 'Ontem';
  }

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
