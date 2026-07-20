import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/formatting/money.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../domain/account.dart';
import '../domain/institution.dart';
import 'controllers/accounts_controller.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key, this.firstAccount = false});

  final bool firstAccount;

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(accountsControllerProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(accountsControllerProvider);

    return LedgerScaffold(
      title: widget.firstAccount ? 'Primeira conta' : 'Minhas contas',
      subtitle: widget.firstAccount
          ? 'Cadastre uma conta para iniciar seu fluxo financeiro.'
          : 'Carteiras, bancos e saldos do workspace ativo.',
      showBrand: !widget.firstAccount,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filled(
            tooltip: 'Adicionar conta',
            onPressed: controller.isLoading ? null : _openAccountForm,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
      children: [
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
            onRetry: () => ref.read(accountsControllerProvider).load(),
          )
        else if (controller.accounts.isEmpty)
          _EmptyAccountsCard(onCreate: _openAccountForm)
        else ...[
          _TotalCard(totalCents: controller.totalIncludedCents),
          const SizedBox(height: 16),
          ...controller.accounts.map(
            (account) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AccountTile(account: account),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openAccountForm() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AccountFormSheet(),
    );

    if (created == true && mounted) {
      await ref.read(accountsControllerProvider).load();
    }
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalCents});

  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            child: Icon(Icons.account_balance_wallet_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total incluido',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            Money.formatCents(totalCents),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final Account account;

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
            child: Icon(_iconFromKey(account.icon)),
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
                  account.type.label,
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

class _EmptyAccountsCard extends StatelessWidget {
  const _EmptyAccountsCard({required this.onCreate});

  final VoidCallback onCreate;

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
            'Nenhuma conta cadastrada',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira conta para acompanhar saldos e movimentacoes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
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

class _AccountFormSheet extends ConsumerStatefulWidget {
  const _AccountFormSheet();

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0,00');
  AccountType _type = AccountType.checking;
  Institution? _institution;
  bool _includeInTotal = true;
  String _color = '#4F46E5';
  final String _icon = 'bank';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(accountsControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova conta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                validator: _requiredName,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.wallet_outlined),
                ),
                items: AccountType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Institution>(
                initialValue: _institution,
                decoration: const InputDecoration(
                  labelText: 'Instituicao',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
                items: controller.institutions
                    .map(
                      (institution) => DropdownMenuItem(
                        value: institution,
                        child: Text(institution.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _institution = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descricao',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _accountColors
                    .map(
                      (color) => _ColorSwatch(
                        color: color,
                        selected: _color == color,
                        onTap: () => setState(() => _color = color),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Incluir no saldo total'),
                value: _includeInTotal,
                onChanged: (value) => setState(() => _includeInTotal = value),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: controller.isSaving ? null : _submit,
                icon: controller.isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Salvar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredName(String? value) {
    if ((value?.trim() ?? '').length < 2) {
      return 'Informe o nome da conta.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final request = CreateAccountRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      institutionId: _institution?.id,
      color: _color,
      icon: _icon,
      includeInTotal: _includeInTotal,
      initialBalanceCents: Money.parseInputToCents(
        _initialBalanceController.text,
      ),
    );
    final success = await ref.read(accountsControllerProvider).create(request);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    final error = ref.read(accountsControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel criar a conta.')),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parsedColor = _colorFromHex(color) ?? AppColors.primaryContainer;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: parsedColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.onSurface : Colors.transparent,
            width: 2,
          ),
        ),
        child: selected ? const Icon(Icons.check, size: 18) : null,
      ),
    );
  }
}

const _accountColors = [
  '#4F46E5',
  '#3B82F6',
  '#06B6D4',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
];

IconData _iconFromKey(String? key) {
  return switch (key) {
    'wallet' => Icons.account_balance_wallet_outlined,
    'card' => Icons.credit_card,
    'cash' => Icons.payments_outlined,
    'investment' => Icons.trending_up,
    _ => Icons.account_balance_outlined,
  };
}

Color? _colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return null;
  }

  return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
}
