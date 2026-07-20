import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/domain/transaction_entry_type.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          widget.navigationShell,
          if (_menuOpen) _QuickActionScrim(onDismiss: _toggleMenu),
          if (_menuOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 86,
              child: SafeArea(
                top: false,
                child: _QuickActionMenu(onSelect: _handleQuickAction),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _LedgerBottomBar(
        selectedIndex: widget.navigationShell.currentIndex,
        menuOpen: _menuOpen,
        onDestinationSelected: _selectDestination,
        onToggleMenu: _toggleMenu,
      ),
    );
  }

  void _selectDestination(int index) {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
  }

  void _handleQuickAction(TransactionEntryType type) {
    setState(() => _menuOpen = false);
    openNewTransactionSheet(context, initialType: type);
  }
}

class _LedgerBottomBar extends StatelessWidget {
  const _LedgerBottomBar({
    required this.selectedIndex,
    required this.menuOpen,
    required this.onDestinationSelected,
    required this.onToggleMenu,
  });

  final int selectedIndex;
  final bool menuOpen;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleMenu;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76 + bottomPadding,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    _BottomBarItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      label: 'Principal',
                      selected: selectedIndex == 0,
                      onTap: () => onDestinationSelected(0),
                    ),
                    _BottomBarItem(
                      icon: Icons.format_list_bulleted,
                      selectedIcon: Icons.format_list_bulleted,
                      label: 'Transações',
                      selected: selectedIndex == 1,
                      onTap: () => onDestinationSelected(1),
                    ),
                    const Expanded(child: SizedBox()),
                    _BottomBarItem(
                      icon: Icons.bar_chart_outlined,
                      selectedIcon: Icons.bar_chart,
                      label: 'Relatórios',
                      selected: selectedIndex == 2,
                      onTap: () => onDestinationSelected(2),
                    ),
                    _BottomBarItem(
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person,
                      label: 'Perfil',
                      selected: selectedIndex == 3,
                      onTap: () => onDestinationSelected(3),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -26,
                child: SizedBox.square(
                  dimension: 72,
                  child: FloatingActionButton(
                    heroTag: 'ledgerflow-quick-actions',
                    elevation: 0,
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    onPressed: onToggleMenu,
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: menuOpen ? .125 : 0,
                      child: Icon(menuOpen ? Icons.close : Icons.add, size: 34),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionScrim extends StatelessWidget {
  const _QuickActionScrim({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: Colors.black.withValues(alpha: .72),
        ),
      ),
    );
  }
}

class _QuickActionMenu extends StatelessWidget {
  const _QuickActionMenu({required this.onSelect});

  final ValueChanged<TransactionEntryType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(-.86, .48),
              child: _QuickActionButton(
                label: TransactionEntryType.transfer.label,
                icon: Icons.swap_horiz,
                iconColor: AppColors.primary,
                onTap: () => onSelect(TransactionEntryType.transfer),
              ),
            ),
            Align(
              alignment: const Alignment(-.34, -.48),
              child: _QuickActionButton(
                label: TransactionEntryType.income.label,
                icon: Icons.trending_up,
                iconColor: AppColors.emerald,
                onTap: () => onSelect(TransactionEntryType.income),
              ),
            ),
            Align(
              alignment: const Alignment(.34, -.48),
              child: _QuickActionButton(
                label: TransactionEntryType.cardExpense.label,
                icon: Icons.credit_card,
                iconColor: AppColors.tertiary,
                onTap: () => onSelect(TransactionEntryType.cardExpense),
              ),
            ),
            Align(
              alignment: const Alignment(.86, .48),
              child: _QuickActionButton(
                label: TransactionEntryType.expense.label,
                icon: Icons.trending_down,
                iconColor: AppColors.error,
                onTap: () => onSelect(TransactionEntryType.expense),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(56),
      onTap: onTap,
      child: SizedBox(
        width: 128,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.surfaceHighest,
              foregroundColor: iconColor,
              child: Icon(icon, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
