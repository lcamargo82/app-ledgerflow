import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/icons/ledger_icon_mapper.dart';
import '../../../core/widgets/ledger_scaffold.dart';
import '../../../core/widgets/lf_card.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../workspaces/presentation/controllers/workspace_collaboration_controller.dart';
import '../../workspaces/presentation/workspace_permissions.dart';
import '../domain/category.dart';
import 'controllers/categories_controller.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(categoriesControllerProvider).load();
      ref.read(workspaceCollaborationControllerProvider).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(categoriesControllerProvider);
    final canWrite = canWriteWorkspace(
      auth: ref.watch(authControllerProvider),
      collaboration: ref.watch(workspaceCollaborationControllerProvider),
    );

    return LedgerScaffold(
      title: 'Categorias',
      subtitle: 'Organize receitas e despesas por cores e icones.',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filled(
            tooltip: 'Adicionar categoria',
            onPressed: controller.isLoading || !canWrite
                ? null
                : _openCategoryForm,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
      children: [
        TextField(
          controller: _searchController,
          onSubmitted: (value) {
            ref.read(categoriesControllerProvider).load(search: value);
          },
          decoration: InputDecoration(
            labelText: 'Buscar categoria',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Buscar',
              onPressed: () {
                ref
                    .read(categoriesControllerProvider)
                    .load(search: _searchController.text);
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Receitas'),
            Tab(text: 'Despesas'),
          ],
        ),
        const SizedBox(height: 16),
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
            onRetry: () => ref.read(categoriesControllerProvider).load(),
          )
        else
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .58,
            child: TabBarView(
              controller: _tabController,
              children: [
                _CategoryList(
                  categories: controller.byType(CategoryType.income),
                  emptyLabel: 'Nenhuma categoria de receita',
                  onCreate: canWrite
                      ? () => _openCategoryForm(CategoryType.income)
                      : null,
                ),
                _CategoryList(
                  categories: controller.byType(CategoryType.expense),
                  emptyLabel: 'Nenhuma categoria de despesa',
                  onCreate: canWrite
                      ? () => _openCategoryForm(CategoryType.expense)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openCategoryForm([CategoryType? initialType]) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => _CategoryFormSheet(
        initialType:
            initialType ??
            (_tabController.index == 0
                ? CategoryType.income
                : CategoryType.expense),
      ),
    );

    if (created == true && mounted) {
      await ref.read(categoriesControllerProvider).load();
    }
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.emptyLabel,
    required this.onCreate,
  });

  final List<Category> categories;
  final String emptyLabel;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _EmptyCategoriesCard(label: emptyLabel, onCreate: onCreate);
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _CategoryTile(category: categories[index]);
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(category.color) ?? AppColors.surfaceHigh;

    return LfCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            foregroundColor: Colors.white,
            child: Icon(LedgerIconMapper.fromKey(category.icon)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  category.isSystemDefault
                      ? 'Padrao do sistema'
                      : category.type.label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (category.isSystemDefault)
            const Icon(Icons.lock_outline, color: AppColors.outline),
        ],
      ),
    );
  }
}

class _EmptyCategoriesCard extends StatelessWidget {
  const _EmptyCategoriesCard({required this.label, required this.onCreate});

  final String label;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return LfCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.category_outlined,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma categoria para classificar seus lancamentos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar categoria'),
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

class _CategoryFormSheet extends ConsumerStatefulWidget {
  const _CategoryFormSheet({required this.initialType});

  final CategoryType initialType;

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late CategoryType _type = widget.initialType;
  String _color = '#4F46E5';
  String _icon = 'tag';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(categoriesControllerProvider);

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
                        'Nova categoria',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        validator: _requiredName,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<CategoryType>(
                        segments: const [
                          ButtonSegment(
                            value: CategoryType.income,
                            label: Text('Receita'),
                          ),
                          ButtonSegment(
                            value: CategoryType.expense,
                            label: Text('Despesa'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selected) {
                          setState(() => _type = selected.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cor',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categoryColors
                            .map(
                              (color) => _ColorSwatch(
                                color: color,
                                selected: _color == color,
                                onTap: () => setState(() => _color = color),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Icone',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categoryIcons
                            .map(
                              (icon) => _IconChoice(
                                icon: icon,
                                selected: _icon == icon,
                                onTap: () => setState(() => _icon = icon),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.isSaving ? null : _submit,
                icon: controller.isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Salvar categoria'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredName(String? value) {
    if ((value?.trim() ?? '').length < 2) {
      return 'Informe o nome da categoria.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final request = CreateCategoryRequest(
      name: _nameController.text.trim(),
      type: _type,
      color: _color,
      icon: _icon,
    );
    final success = await ref
        .read(categoriesControllerProvider)
        .create(request);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    final error = ref.read(categoriesControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Nao foi possivel criar a categoria.')),
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

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Icon(LedgerIconMapper.fromKey(icon)),
      ),
    );
  }
}

const _categoryColors = [
  '#4F46E5',
  '#3B82F6',
  '#06B6D4',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
  '#EC4899',
];

const _categoryIcons = [
  'tag',
  'utensils',
  'home',
  'transport',
  'shopping',
  'health',
  'education',
  'salary',
  'gift',
];

Color? _colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return null;
  }

  return Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
}
