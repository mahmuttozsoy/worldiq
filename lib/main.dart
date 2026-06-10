import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/shared_prefs_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'data/vocabulary.dart';
import 'services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:world_iq/l10n/generated/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  await loadVocabularyData();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const WorldIQApp(),
    ),
  );
}

class WorldIQApp extends ConsumerWidget {
  const WorldIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'WorldIQ',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo 500
          brightness: Brightness.light,
          surface: const Color(0xFFFFFFFF), // White surface
          surfaceContainer: const Color(0xFFF8FAFC), // Slate 50 container
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme)
            .copyWith(
              displayLarge: GoogleFonts.outfit(
                color: const Color(0xFF0F172A), // Slate 900
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: GoogleFonts.outfit(
                color: const Color(0xFF1E293B), // Slate 800
              ),
              bodyMedium: GoogleFonts.outfit(
                color: const Color(0xFF475569), // Slate 600
              ),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        pageTransitionsTheme: _pageTransitionsTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF020617),
        pageTransitionsTheme: _pageTransitionsTheme,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  );
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020617),
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 3,
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null && user.isAnonymous) {
          FirebaseAuth.instance.signOut();
          return const LoginScreen();
        }

        return user != null ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
