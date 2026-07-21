import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/workspace_collaboration.dart';
import 'controllers/workspace_collaboration_controller.dart';

class WorkspaceCollaborationScreen extends ConsumerStatefulWidget {
  const WorkspaceCollaborationScreen({super.key});

  @override
  ConsumerState<WorkspaceCollaborationScreen> createState() =>
      _WorkspaceCollaborationScreenState();
}

class _WorkspaceCollaborationScreenState
    extends ConsumerState<WorkspaceCollaborationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(workspaceCollaborationControllerProvider).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final controller = ref.watch(workspaceCollaborationControllerProvider);
    final currentRole = controller.roleForUser(auth.me?.userId ?? '');
    final canManage = currentRole?.canManageMembers ?? false;

    return LedgerScaffold(
      title: 'Compartilhamento',
      subtitle: 'Membros e convites do workspace ativo.',
      children: [
        if (controller.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (controller.errorMessage != null)
          _ErrorCard(
            message: controller.errorMessage!,
            onRetry: () =>
                ref.read(workspaceCollaborationControllerProvider).load(),
          )
        else ...[
          SectionHeader(
            title: 'Membros',
            actionLabel: canManage ? 'Convidar' : null,
            onAction: canManage ? _openInvitationForm : null,
          ),
          const SizedBox(height: 8),
          if (controller.members.isEmpty)
            const LfCard(child: Text('Nenhum membro encontrado.'))
          else
            ...controller.members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MemberTile(
                  member: member,
                  currentUserId: auth.me?.userId ?? '',
                  canManage: canManage,
                  isSaving: controller.isSaving,
                  onChangeRole: (role) => _changeRole(member, role),
                  onRemove: () => _removeMember(member),
                ),
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Convites',
            actionLabel: canManage ? 'Novo' : null,
            onAction: canManage ? _openInvitationForm : null,
          ),
          const SizedBox(height: 8),
          if (controller.invitationsErrorMessage != null)
            _InlineWarning(message: controller.invitationsErrorMessage!)
          else if (controller.invitations.isEmpty)
            const LfCard(child: Text('Nenhum convite pendente.'))
          else
            ...controller.invitations.map(
              (invitation) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _InvitationTile(
                  invitation: invitation,
                  canManage: canManage,
                  isSaving: controller.isSaving,
                  onCancel: () => _cancelInvitation(invitation),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _openInvitationForm() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _InvitationFormSheet(),
    );

    if (!mounted || created != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Convite criado com sucesso.')),
    );
  }

  Future<void> _changeRole(WorkspaceMember member, WorkspaceRole role) async {
    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .updateMember(memberId: member.id, role: role);

    if (!mounted || success) {
      return;
    }

    _showControllerError();
  }

  Future<void> _removeMember(WorkspaceMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover membro?'),
        content: Text(
          'Remover ${member.user?.name ?? member.user?.email ?? 'este membro'} do workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .removeMember(member.id);

    if (!mounted || success) {
      return;
    }

    _showControllerError();
  }

  Future<void> _cancelInvitation(WorkspaceInvitation invitation) async {
    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .cancelInvitation(invitation.id);

    if (!mounted || success) {
      return;
    }

    _showControllerError();
  }

  void _showControllerError() {
    final error = ref
        .read(workspaceCollaborationControllerProvider)
        .errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel atualizar.')),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.currentUserId,
    required this.canManage,
    required this.isSaving,
    required this.onChangeRole,
    required this.onRemove,
  });

  final WorkspaceMember member;
  final String currentUserId;
  final bool canManage;
  final bool isSaving;
  final ValueChanged<WorkspaceRole> onChangeRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final title = member.user?.name.isNotEmpty == true
        ? member.user!.name
        : member.user?.email ?? 'Membro';
    final isCurrentUser = member.userId == currentUserId;

    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.primary,
            child: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  [
                    if (member.user?.email.isNotEmpty == true)
                      member.user!.email,
                    member.role.label,
                    if (isCurrentUser) 'voce',
                  ].join(' • '),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (canManage && !isSaving)
            PopupMenuButton<String>(
              tooltip: 'Acoes do membro',
              onSelected: (value) {
                if (value == 'remove') {
                  onRemove();
                  return;
                }

                onChangeRole(WorkspaceRole.fromApi(value));
              },
              itemBuilder: (context) => [
                ...WorkspaceRole.values.map(
                  (role) => PopupMenuItem(
                    value: role.apiValue,
                    enabled: role != member.role,
                    child: Text(role.label),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remover membro'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  const _InvitationTile({
    required this.invitation,
    required this.canManage,
    required this.isSaving,
    required this.onCancel,
  });

  final WorkspaceInvitation invitation;
  final bool canManage;
  final bool isSaving;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.primary,
            child: const Icon(Icons.mail_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${invitation.role.label} • ${invitation.status.label}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (canManage &&
              !isSaving &&
              invitation.status == WorkspaceInvitationStatus.pending)
            IconButton(
              tooltip: 'Cancelar convite',
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}

class _InvitationFormSheet extends ConsumerStatefulWidget {
  const _InvitationFormSheet();

  @override
  ConsumerState<_InvitationFormSheet> createState() =>
      _InvitationFormSheetState();
}

class _InvitationFormSheetState extends ConsumerState<_InvitationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  WorkspaceRole _role = WorkspaceRole.editor;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(workspaceCollaborationControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo convite',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WorkspaceRole>(
              initialValue: _role,
              dropdownColor: AppColors.surfaceHighest,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                labelText: 'Permissao',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined),
              ),
              items: WorkspaceRole.values
                  .where((role) => role != WorkspaceRole.owner)
                  .map(
                    (role) =>
                        DropdownMenuItem(value: role, child: Text(role.label)),
                  )
                  .toList(),
              onChanged: controller.isSaving
                  ? null
                  : (role) => setState(() => _role = role ?? _role),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.isSaving ? null : _submit,
              icon: controller.isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text('Enviar convite'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (!email.contains('@') || !email.contains('.')) {
      return 'Informe um email valido.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await ref
        .read(workspaceCollaborationControllerProvider)
        .createInvitation(
          CreateWorkspaceInvitationRequest(
            email: _emailController.text,
            role: _role,
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    final error = ref
        .read(workspaceCollaborationControllerProvider)
        .errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel criar o convite.')),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LfCard(borderColor: AppColors.outlineVariant, child: Text(message));
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

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
