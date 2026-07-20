class Money {
  const Money._();

  static int parseCents(Object? value) {
    if (value == null) {
      return 0;
    }

    final raw = value.toString().replaceAll(',', '.').trim();
    final negative = raw.startsWith('-');
    final normalized = negative ? raw.substring(1) : raw;
    final parts = normalized.split('.');
    final reais = int.tryParse(parts.first) ?? 0;
    final centsRaw = parts.length > 1 ? parts[1] : '';
    final centsPadded = centsRaw.padRight(2, '0');
    final cents = int.tryParse(centsPadded.substring(0, 2)) ?? 0;
    final total = reais * 100 + cents;

    return negative ? -total : total;
  }

  static int parseInputToCents(String input) {
    final clean = input
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    final value = double.tryParse(clean) ?? 0;

    return (value * 100).round();
  }

  static double centsToDecimal(int cents) => cents / 100;

  static String formatCents(int cents) {
    final negative = cents < 0;
    final absolute = cents.abs();
    final reais = absolute ~/ 100;
    final centavos = absolute % 100;
    final sign = negative ? '-' : '';

    return '${sign}R\$ ${_groupThousands(reais)},${centavos.toString().padLeft(2, '0')}';
  }

  static String _groupThousands(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
