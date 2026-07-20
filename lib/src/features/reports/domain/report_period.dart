class ReportPeriod {
  const ReportPeriod({required this.month, required this.year});

  final int month;
  final int year;

  factory ReportPeriod.current() {
    final now = DateTime.now();

    return ReportPeriod(month: now.month, year: now.year);
  }

  ReportPeriod previous() {
    if (month == 1) {
      return ReportPeriod(month: 12, year: year - 1);
    }

    return ReportPeriod(month: month - 1, year: year);
  }

  ReportPeriod next() {
    if (month == 12) {
      return ReportPeriod(month: 1, year: year + 1);
    }

    return ReportPeriod(month: month + 1, year: year);
  }

  String get label => '${monthLabel(month)} $year';

  static String monthLabel(int month) {
    return switch (month) {
      1 => 'Janeiro',
      2 => 'Fevereiro',
      3 => 'Marco',
      4 => 'Abril',
      5 => 'Maio',
      6 => 'Junho',
      7 => 'Julho',
      8 => 'Agosto',
      9 => 'Setembro',
      10 => 'Outubro',
      11 => 'Novembro',
      12 => 'Dezembro',
      _ => 'Mes',
    };
  }
}
