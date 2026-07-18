import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgerflow/src/app/app.dart';

void main() {
  testWidgets('shows LedgerFlow login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedgerFlowApp()));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
