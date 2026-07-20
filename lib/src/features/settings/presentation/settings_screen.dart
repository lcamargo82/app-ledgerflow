import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return LedgerScaffold(
      title: 'Configurações',
      subtitle: 'Perfil, preferencias e seguranca da conta.',
      children: [
        _ProfileCard(
          name: auth.profile?.name ?? auth.me?.email ?? 'Usuario',
          email: auth.profile?.email ?? auth.me?.email ?? '',
        ),
        const SizedBox(height: 24),
        _SettingsTile(
          icon: Icons.account_balance_outlined,
          title: 'Minhas contas',
          subtitle: 'Carteiras, bancos e saldos',
          onTap: () => context.go('/settings/accounts'),
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
          onPressed: auth.isLoading
              ? null
              : () async {
                  await ref.read(authControllerProvider).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.email});

  final String name;
  final String email;

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
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: LfCard(
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
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
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
