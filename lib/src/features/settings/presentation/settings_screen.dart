import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../workspaces/presentation/controllers/workspace_collaboration_controller.dart';
import '../../workspaces/presentation/widgets/workspace_switcher_card.dart';
import 'controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsControllerProvider).load();
      await ref.read(authControllerProvider).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final profile = auth.profile;
    final email = profile?.email ?? auth.me?.email ?? '';
    final name = profile?.name.isNotEmpty == true ? profile!.name : email;

    return LedgerScaffold(
      title: 'Perfil',
      subtitle: 'Conta, preferencias e seguranca.',
      children: [
        if (auth.isLoading && profile == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _ProfileCard(
            name: name.isEmpty ? 'Usuario' : name,
            email: email,
            onEdit: () => _openProfileForm(name: name, email: email),
          ),
        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          _InlineError(message: auth.errorMessage!),
        ],
        const SizedBox(height: 24),
        WorkspaceSwitcherCard(
          onChanged: () =>
              ref.read(workspaceCollaborationControllerProvider).load(),
        ),
        const SizedBox(height: 16),
        _SettingsTile(
          icon: Icons.account_balance_outlined,
          title: 'Minhas contas',
          subtitle: 'Carteiras, bancos e saldos',
          onTap: () => context.go('/settings/accounts'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.category_outlined,
          title: 'Categorias',
          subtitle: 'Receitas, despesas e orcamentos',
          onTap: () => context.go('/settings/categories'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.groups_outlined,
          title: 'Compartilhamento',
          subtitle: 'Membros e convites do workspace',
          onTap: () => context.go('/settings/collaboration'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.lock_outline,
          title: 'Trocar senha',
          subtitle: 'Atualize sua senha de acesso',
          onTap: _openPasswordForm,
        ),
        const SizedBox(height: 8),
        const _SettingsTile(
          icon: Icons.attach_money,
          title: 'Moeda',
          subtitle: 'Real brasileiro (BRL)',
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Tema escuro',
          subtitle: 'Padrao visual do app',
          value: settings.preferences.darkThemeEnabled,
          onChanged: settings.isLoading
              ? null
              : (value) => ref
                    .read(settingsControllerProvider)
                    .setDarkThemeEnabled(value),
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          icon: Icons.fingerprint,
          title: 'Biometria',
          subtitle: 'Preferencia local para acesso futuro',
          value: settings.preferences.biometricsEnabled,
          onChanged: settings.isLoading
              ? null
              : (value) => ref
                    .read(settingsControllerProvider)
                    .setBiometricsEnabled(value),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: auth.isLoading ? null : _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }

  Future<void> _openProfileForm({
    required String name,
    required String email,
  }) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => _ProfileFormSheet(name: name, email: email),
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso.')),
    );
  }

  Future<void> _openPasswordForm() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => const _PasswordFormSheet(),
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha atualizada com sucesso.')),
    );
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider).logout();

    if (mounted) {
      context.go('/login');
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  final String name;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              _initials(name, email),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
            onPressed: onEdit,
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
            if (onTap != null) const Icon(Icons.chevron_right),
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
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProfileFormSheet extends ConsumerStatefulWidget {
  const _ProfileFormSheet({required this.name, required this.email});

  final String name;
  final String email;

  @override
  ConsumerState<_ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends ConsumerState<_ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return _SettingsFormSheet(
      title: 'Editar perfil',
      buttonLabel: 'Salvar perfil',
      isSaving: auth.isLoading,
      onSubmit: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              validator: _requiredName,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _requiredEmail,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredName(String? value) {
    if ((value?.trim() ?? '').length < 2) {
      return 'Informe seu nome.';
    }

    return null;
  }

  String? _requiredEmail(String? value) {
    final email = value?.trim() ?? '';

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Informe um e-mail valido.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await ref
        .read(authControllerProvider)
        .updateProfile(
          name: _nameController.text,
          email: _emailController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    _showAuthError(context, ref);
  }
}

class _PasswordFormSheet extends ConsumerStatefulWidget {
  const _PasswordFormSheet();

  @override
  ConsumerState<_PasswordFormSheet> createState() => _PasswordFormSheetState();
}

class _PasswordFormSheetState extends ConsumerState<_PasswordFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _hideOldPassword = true;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return _SettingsFormSheet(
      title: 'Trocar senha',
      buttonLabel: 'Salvar senha',
      isSaving: auth.isLoading,
      onSubmit: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: _hideOldPassword,
              validator: _requiredPassword,
              decoration: InputDecoration(
                labelText: 'Senha atual',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _hideOldPassword
                      ? 'Mostrar senha atual'
                      : 'Ocultar senha atual',
                  onPressed: () {
                    setState(() => _hideOldPassword = !_hideOldPassword);
                  },
                  icon: Icon(
                    _hideOldPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              validator: _strongPassword,
              decoration: InputDecoration(
                labelText: 'Nova senha',
                prefixIcon: const Icon(Icons.password_outlined),
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmationController,
              obscureText: _hideConfirmation,
              validator: _samePassword,
              decoration: InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  tooltip: _hideConfirmation
                      ? 'Mostrar confirmacao'
                      : 'Ocultar confirmacao',
                  onPressed: () {
                    setState(() => _hideConfirmation = !_hideConfirmation);
                  },
                  icon: Icon(
                    _hideConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Informe a senha atual.';
    }

    return null;
  }

  String? _strongPassword(String? value) {
    final password = value ?? '';
    final hasLowercase = RegExp('[a-z]').hasMatch(password);
    final hasUppercase = RegExp('[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (password.length < 8) {
      return 'Use pelo menos 8 caracteres.';
    }

    if (!hasLowercase || !hasUppercase || !hasNumber) {
      return 'Use maiuscula, minuscula e numero.';
    }

    return null;
  }

  String? _samePassword(String? value) {
    if (value != _passwordController.text) {
      return 'As senhas precisam ser iguais.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await ref
        .read(authControllerProvider)
        .changePassword(
          oldPassword: _oldPasswordController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    _showAuthError(context, ref);
  }
}

class _SettingsFormSheet extends StatelessWidget {
  const _SettingsFormSheet({
    required this.title,
    required this.buttonLabel,
    required this.isSaving,
    required this.onSubmit,
    required this.child,
  });

  final String title;
  final String buttonLabel;
  final bool isSaving;
  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .78,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
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
                    child,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isSaving ? null : onSubmit,
              icon: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.error,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _initials(String name, String email) {
  final source = name.trim().isNotEmpty ? name.trim() : email.trim();

  if (source.isEmpty) {
    return 'U';
  }

  final parts = source.split(RegExp(r'\s+'));
  final first = parts.first.characters.first.toUpperCase();

  if (parts.length == 1) {
    return first;
  }

  return '$first${parts.last.characters.first.toUpperCase()}';
}

void _showAuthError(BuildContext context, WidgetRef ref) {
  final error = ref.read(authControllerProvider).errorMessage;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error ?? 'Nao foi possivel concluir a acao.')),
  );
}
