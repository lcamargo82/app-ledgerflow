import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/lf_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'controllers/workspace_collaboration_controller.dart';

class WorkspaceInvitationResponseScreen extends ConsumerStatefulWidget {
  const WorkspaceInvitationResponseScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<WorkspaceInvitationResponseScreen> createState() =>
      _WorkspaceInvitationResponseScreenState();
}

class _WorkspaceInvitationResponseScreenState
    extends ConsumerState<WorkspaceInvitationResponseScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = ref.read(authControllerProvider);

      if (auth.status == AuthStatus.unknown) {
        auth.boot();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final collaboration = ref.watch(workspaceCollaborationControllerProvider);
    final token = widget.token.trim();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: LfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.group_add_outlined,
                      size: 52,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Convite para workspace',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aceite o convite para acessar contas, transacoes e relatorios compartilhados.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (token.isEmpty)
                      const _InvitationMessage(
                        icon: Icons.link_off_outlined,
                        message: 'Token de convite ausente ou invalido.',
                      )
                    else if (auth.status == AuthStatus.unknown ||
                        auth.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (!auth.isAuthenticated)
                      _UnauthenticatedActions(token: token)
                    else
                      _AuthenticatedActions(
                        isSaving: collaboration.isSaving,
                        onAccept: _accept,
                        onDecline: _decline,
                      ),
                    if (collaboration.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _InvitationMessage(
                        icon: Icons.error_outline,
                        message: collaboration.errorMessage!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _accept() async {
    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .acceptInvitation(widget.token);

    if (!mounted || !success) {
      return;
    }

    await ref.read(authControllerProvider).refreshMe();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Convite aceito com sucesso.')),
    );
    context.go('/dashboard');
  }

  Future<void> _decline() async {
    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .declineInvitation(widget.token);

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Convite recusado.')));
    context.go('/dashboard');
  }
}

class _UnauthenticatedActions extends StatelessWidget {
  const _UnauthenticatedActions({required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final encodedToken = Uri.encodeComponent(token);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InvitationMessage(
          icon: Icons.lock_outline,
          message:
              'Entre ou crie uma conta com o email convidado para continuar.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go('/login?invitationToken=$encodedToken'),
          icon: const Icon(Icons.login),
          label: const Text('Entrar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/signup?invitationToken=$encodedToken'),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Criar conta'),
        ),
      ],
    );
  }
}

class _AuthenticatedActions extends StatelessWidget {
  const _AuthenticatedActions({
    required this.isSaving,
    required this.onAccept,
    required this.onDecline,
  });

  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isSaving ? null : onAccept,
          icon: isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Aceitar convite'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isSaving ? null : onDecline,
          icon: const Icon(Icons.close),
          label: const Text('Recusar convite'),
        ),
      ],
    );
  }
}

class _InvitationMessage extends StatelessWidget {
  const _InvitationMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
