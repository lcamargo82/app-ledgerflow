import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerflow/src/features/reports/domain/report_period.dart';

void main() {
  test('moves to previous period across year boundary', () {
    final period = const ReportPeriod(month: 1, year: 2026).previous();

    expect(period.month, 12);
    expect(period.year, 2025);
    expect(period.label, 'Dezembro 2025');
  });

  test('moves to next period across year boundary', () {
    final period = const ReportPeriod(month: 12, year: 2026).next();

    expect(period.month, 1);
    expect(period.year, 2027);
    expect(period.label, 'Janeiro 2027');
  });
}
