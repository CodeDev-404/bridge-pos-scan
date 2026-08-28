import 'package:flutter_test/flutter_test.dart';
import 'package:bridge_pos_scan/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const BridgePosScanApp());
    await tester.pumpAndSettle();
    expect(find.text('Bridge+ POS Scan'), findsOneWidget);
  });
}
