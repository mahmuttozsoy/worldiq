import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:world_iq/main.dart';
import 'package:world_iq/providers/shared_prefs_provider.dart';

void main() {
  testWidgets('WorldIQ home screen smoke test', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const WorldIQApp(),
      ),
    );

    await tester.pump();

    expect(find.text('WorldIQ'), findsOneWidget);
    expect(find.text('Dil Akademisi'), findsOneWidget);
  });
}
