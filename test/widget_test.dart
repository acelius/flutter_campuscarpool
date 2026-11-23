import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Campus Carpool basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Campus Carpool'),
      ),
    );

    expect(find.text('Campus Carpool'), findsOneWidget);
  });
}
