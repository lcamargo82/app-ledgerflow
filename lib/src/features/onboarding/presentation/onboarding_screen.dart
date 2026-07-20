import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/lf_card.dart';
import '../domain/onboarding_choice.dart';
import 'controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingChoice? _choice;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardingControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 56,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Como voce deseja usar o LedgerFlow?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vamos criar seus espacos financeiros iniciais e categorias padrao.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ...OnboardingChoice.values.map(
                        (choice) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChoiceCard(
                            choice: choice,
                            selected: _choice == choice,
                            onTap: controller.isLoading
                                ? null
                                : () => setState(() => _choice = choice),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: controller.isLoading || _choice == null
                            ? null
                            : _submit,
                        icon: controller.isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: const Text('Continuar'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final choice = _choice;

    if (choice == null) {
      return;
    }

    final success = await ref.read(onboardingControllerProvider).submit(choice);

    if (!mounted || success) {
      return;
    }

    final error = ref.read(onboardingControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Nao foi possivel configurar sua conta.'),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final OnboardingChoice choice;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: LfCard(
        color: selected ? AppColors.surfaceHigh : AppColors.surfaceContainer,
        borderColor: selected ? AppColors.primary : AppColors.outlineVariant,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? AppColors.primaryContainer
                  : AppColors.surfaceHigh,
              foregroundColor: selected ? Colors.white : AppColors.primary,
              child: Icon(_iconFor(choice)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    choice.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    choice.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.emerald),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(OnboardingChoice choice) {
    return switch (choice) {
      OnboardingChoice.personal => Icons.person_outline,
      OnboardingChoice.business => Icons.storefront_outlined,
      OnboardingChoice.both => Icons.space_dashboard_outlined,
    };
  }
}
