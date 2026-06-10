import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'language_academy_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'friends_screen.dart';
import 'package:world_iq/services/firebase_service.dart';
import '../providers/locale_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set online initially
    _updatePresence(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Note: disposing might not catch all exit cases, handled by lifecycle
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePresence(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _updatePresence(false);
    }
  }

  void _updatePresence(bool isOnline) {
    ref.read(firebaseServiceProvider).updateUserPresence(isOnline);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = <Widget>[
      HomeScreen(key: ValueKey<String>('home_${locale.languageCode}')),
      LanguageAcademyScreen(
        key: ValueKey<String>('academy_${locale.languageCode}'),
      ),
      LeaderboardScreen(
        key: ValueKey<String>('leaderboard_${locale.languageCode}'),
      ),
      FriendsScreen(key: ValueKey<String>('friends_${locale.languageCode}')),
      ProfileScreen(key: ValueKey<String>('profile_${locale.languageCode}')),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6366F1), // Indigo
          unselectedItemColor: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : const Color(0xFF64748B), // Slate 400
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              activeIcon: const Icon(Icons.home_rounded, size: 28),
              label: l10n.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school_rounded),
              activeIcon: const Icon(Icons.school_rounded, size: 28),
              label: l10n.translate('academy'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.leaderboard_rounded),
              activeIcon: const Icon(Icons.leaderboard_rounded, size: 28),
              label: l10n.translate('leaderboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_rounded),
              activeIcon: const Icon(Icons.people_rounded, size: 28),
              label: l10n.translate('friends'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              activeIcon: const Icon(Icons.person_rounded, size: 28),
              label: l10n.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
