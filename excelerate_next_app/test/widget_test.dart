import 'package:flutter_test/flutter_test.dart';
import 'package:excelerate_next_app/main.dart'; 

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    // We are testing our updated main class
    await tester.pumpWidget(const ExcelerateNextApp());
  });
}