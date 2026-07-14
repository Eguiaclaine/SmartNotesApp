import 'package:flutter_test/flutter_test.dart';
import 'package:application/main.dart';

void main() {
  testWidgets('Smart Notes app shows home screen in offline mode', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNotesApp(supabaseReady: false));

    expect(find.text('Smart Notes'), findsOneWidget);
  });
}
