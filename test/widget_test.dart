import 'package:flutter_test/flutter_test.dart';
import 'package:application/main.dart';

void main() {
  testWidgets('NoteVault unavailable backend screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNotesApp(supabaseReady: false));

    expect(find.text('Backend not configured'), findsOneWidget);
  });
}
