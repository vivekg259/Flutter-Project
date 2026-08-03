import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:excelerate_next_app/app.dart';
import 'package:excelerate_next_app/providers/announcement_provider.dart';
import 'package:excelerate_next_app/providers/auth_provider.dart';
import 'package:excelerate_next_app/providers/program_provider.dart';
import 'package:excelerate_next_app/providers/registration_provider.dart';

void main() {
  testWidgets('App launch test', (WidgetTester tester) async {
    // Builds the root app wrapped in MultiProvider, exactly like main.dart
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ChangeNotifierProvider<ProgramProvider>(
            create: (_) => ProgramProvider(),
          ),
          ChangeNotifierProvider<AnnouncementProvider>(
            create: (_) => AnnouncementProvider(),
          ),
          ChangeNotifierProvider<RegistrationProvider>(
            create: (_) => RegistrationProvider(),
          ),
        ],
        child: const ExcelerateApp(),
      ),
    );

    // Initial frame renders ExcelerateApp
    expect(find.byType(ExcelerateApp), findsOneWidget);

    // Unmount MultiProvider to dispose all providers and cancel background timers
    await tester.pumpWidget(const SizedBox());
  });
}
