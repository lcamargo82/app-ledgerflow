import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LedgerScaffold(
      title: 'Configurações',
      subtitle: 'Perfil, preferencias e seguranca da conta.',
      children: [
        const _ProfileCard(),
        const SizedBox(height: 24),
        const _SettingsTile(
          icon: Icons.account_balance_outlined,
          title: 'Minhas contas',
          subtitle: 'Carteiras, bancos e saldos',
        ),
        const SizedBox(height: 8),
        const _SettingsTile(
          icon: Icons.category_outlined,
          title: 'Categorias',
          subtitle: 'Receitas, despesas e orcamentos',
        ),
        const SizedBox(height: 8),
        const _SettingsTile(
          icon: Icons.attach_money,
          title: 'Moeda',
          subtitle: 'Real brasileiro (BRL)',
        ),
        const SizedBox(height: 8),
        const _SwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Tema escuro',
          value: true,
        ),
        const SizedBox(height: 8),
        const _SwitchTile(
          icon: Icons.fingerprint,
          title: 'Biometria',
          value: true,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return LfCard(
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              'L',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leandro',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'leandro@ledgerflow.app',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.primary,
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
                Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.tertiary,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(value: value, onChanged: (_) {}),
        ],
      ),
    );
  }
}
