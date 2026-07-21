import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lf_card.dart';
import '../../domain/workspace.dart';
import '../controllers/workspace_controller.dart';

class WorkspaceSwitcherCard extends ConsumerStatefulWidget {
  const WorkspaceSwitcherCard({required this.onChanged, super.key});

  final VoidCallback onChanged;

  @override
  ConsumerState<WorkspaceSwitcherCard> createState() =>
      _WorkspaceSwitcherCardState();
}

class _WorkspaceSwitcherCardState extends ConsumerState<WorkspaceSwitcherCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(workspaceControllerProvider).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(workspaceControllerProvider);
    final activeWorkspace = controller.workspaces
        .where((workspace) => workspace.id == controller.activeWorkspaceId)
        .firstOrNull;

    return LfCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.primary,
            child: Icon(Icons.space_dashboard_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeWorkspace?.name ?? 'Workspace',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  activeWorkspace == null
                      ? 'Carregando workspace ativo'
                      : '${_workspaceTypeLabel(activeWorkspace)} - ${activeWorkspace.currency}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.isLoading || controller.workspaces.length < 2
                ? null
                : _openWorkspacePicker,
            child: const Text('Trocar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWorkspacePicker() async {
    final controller = ref.read(workspaceControllerProvider);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _WorkspacePickerSheet(
        activeWorkspaceId: controller.activeWorkspaceId,
        workspaces: controller.workspaces,
      ),
    );

    if (!mounted ||
        selected == null ||
        selected == controller.activeWorkspaceId) {
      return;
    }

    await ref.read(workspaceControllerProvider).setActiveWorkspace(selected);
    widget.onChanged();
  }
}

class _WorkspacePickerSheet extends StatelessWidget {
  const _WorkspacePickerSheet({
    required this.activeWorkspaceId,
    required this.workspaces,
  });

  final String? activeWorkspaceId;
  final List<Workspace> workspaces;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Trocar workspace',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ...workspaces.map(
              (workspace) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  leading: const Icon(Icons.space_dashboard_outlined),
                  title: Text(workspace.name),
                  subtitle: Text(
                    '${_workspaceTypeLabel(workspace)} - ${workspace.currency}',
                  ),
                  trailing: workspace.id == activeWorkspaceId
                      ? const Icon(Icons.check, color: AppColors.emerald)
                      : null,
                  onTap: () => Navigator.of(context).pop(workspace.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _workspaceTypeLabel(Workspace workspace) {
  return switch (workspace.type) {
    'PERSONAL' => 'Pessoal',
    'BUSINESS' => 'Negocio',
    _ => workspace.type,
  };
}
