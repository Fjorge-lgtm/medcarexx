import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medcare/main.dart';

void main() {
  testWidgets('App starts on RegisterView when there is no PIN yet',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(startWithLogin: false),
      ),
    );

    expect(find.text('Criar conta'), findsOneWidget);
  });
}
