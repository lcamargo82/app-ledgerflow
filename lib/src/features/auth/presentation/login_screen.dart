import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/lf_card.dart';
import 'controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final invitationToken = GoRouterState.of(
      context,
    ).uri.queryParameters['invitationToken'];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LoginBrand(),
                  const SizedBox(height: 32),
                  LfCard(
                    color: AppColors.surfaceContainer.withValues(alpha: .82),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bem-vindo de volta',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Entre para acompanhar seu fluxo financeiro.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _requiredEmail,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'nome@exemplo.com',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            validator: _requiredPassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Digite sua senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Mostrar senha'
                                    : 'Ocultar senha',
                                onPressed: () {
                                  setState(
                                    () => _hidePassword = !_hidePassword,
                                  );
                                },
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _remember,
                                    onChanged: (value) {
                                      setState(
                                        () => _remember = value ?? false,
                                      );
                                    },
                                  ),
                                  const Text('Lembrar de mim'),
                                ],
                              ),
                              TextButton(
                                onPressed: () => context.go('/forgot-password'),
                                child: const Text('Esqueci a senha'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: auth.isLoading ? null : _submit,
                            icon: auth.isLoading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward),
                            label: const Text('Entrar'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                IconButton.filledTonal(
                                  iconSize: 34,
                                  tooltip: 'Entrar com biometria',
                                  onPressed: null,
                                  icon: const Icon(Icons.fingerprint),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Entrar com biometria',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Ainda nao tem conta?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            context.go(_authPath('/signup', invitationToken)),
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    if (!email.contains('@')) {
      return 'Informe um e-mail valido.';
    }

    return null;
  }

  String? _requiredPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Informe sua senha.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await ref
        .read(authControllerProvider)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      final invitationToken = GoRouterState.of(
        context,
      ).uri.queryParameters['invitationToken'];

      if (invitationToken != null && invitationToken.trim().isNotEmpty) {
        context.go(
          '/workspace-invitations/accept?token=${Uri.encodeComponent(invitationToken)}',
        );
      }

      return;
    }

    final error = ref.read(authControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel entrar.')),
    );
  }
}

String _authPath(String path, String? invitationToken) {
  if (invitationToken == null || invitationToken.trim().isEmpty) {
    return path;
  }

  return '$path?invitationToken=${Uri.encodeComponent(invitationToken)}';
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.account_balance_wallet,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineLarge,
            children: const [
              TextSpan(text: 'Ledger'),
              TextSpan(
                text: 'Flow',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Controle pessoal com clareza diaria',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
