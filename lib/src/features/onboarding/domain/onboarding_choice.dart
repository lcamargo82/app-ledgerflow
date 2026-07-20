enum OnboardingChoice {
  personal(
    'PERSONAL',
    'Pessoal',
    'Controle suas contas, gastos e metas do dia a dia.',
  ),
  business(
    'BUSINESS',
    'Negocio',
    'Separe receitas e despesas de uma operacao profissional.',
  ),
  both(
    'BOTH',
    'Ambos',
    'Comece com espacos separados para vida pessoal e negocio.',
  );

  const OnboardingChoice(this.apiValue, this.title, this.description);

  final String apiValue;
  final String title;
  final String description;
}
