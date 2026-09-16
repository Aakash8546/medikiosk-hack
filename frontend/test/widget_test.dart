






import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medikiosk/app/app.dart';

void main() {
  testWidgets('renders the welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediKioskApp(),
      ),
    );

    await tester.pumpAndSettle();

    
    
    expect(find.text('Welcome to MediKiosk'), findsOneWidget);
    expect(find.text('Select Language / भाषा चुनें'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}