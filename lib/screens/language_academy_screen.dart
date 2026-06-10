import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocabulary.dart';
import '../providers/shared_prefs_provider.dart';

import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import 'country_selection_screen.dart';
import 'level_options_screen.dart';
import 'level_unlock_screen.dart';
import 'sudoku_screen.dart';
import 'chess_screen.dart';
import '../data/countries.dart';
import 'dictionary_search_screen.dart';

class LanguageAcademyScreen extends ConsumerStatefulWidget {
  const LanguageAcademyScreen({super.key});

  @override
  ConsumerState<LanguageAcademyScreen> createState() =>
      _LanguageAcademyScreenState();
}

class _LanguageAcademyScreenState extends ConsumerState<LanguageAcademyScreen> {
  late String _selectedCountryId;

  @override
  void initState() {
    super.initState();
    _selectedCountryId = ref
        .read(sharedPrefsServiceProvider)
        .getLanguageCountryId();
  }

  void _changeCountry(String newId) {
    setState(() {
      _selectedCountryId = newId;
    });
    ref.read(sharedPrefsServiceProvider).setLanguageCountryId(newId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final country = countriesData.firstWhere(
      (c) => c.id == _selectedCountryId,
      orElse: () => countriesData.firstWhere((c) => c.id == 'us'),
    );
    final languageName = countryLanguageMap[country.id] ?? country.name;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('academy'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                country.flagPath,
                                width: 100,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate(languageName),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -12,
                      right: -12,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_location_alt_rounded,
                          color: secondaryTextColor.withValues(alpha: 0.6),
                          size: 28,
                        ),
                        onPressed: () async {
                          final newId = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CountrySelectionScreen(),
                            ),
                          );
                          if (newId != null) {
                            _changeCountry(newId);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DictionarySearchScreen(
                        countryId: country.id,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.15 : 0.08),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.4 : 0.25),
                    width: 1.5,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF6366F1),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advanced Dictionary Search',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Search and learn millions of English words',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textColor.withValues(alpha: 0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('education_level'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
                  final level = levels[index];
                  final levelNumber = index + 1;
                  final unlockedLevel =
                      ref.watch(languageLevelProvider)[country.id] ??
                      ref
                          .read(languageLevelProvider.notifier)
                          .getLevel(country.id);
                  final isUnlocked = levelNumber <= unlockedLevel;
                  final isNextLocked = levelNumber == unlockedLevel + 1;

                  return _LevelCard(
                    level: level,
                    isUnlocked: isUnlocked,
                    isNextLocked: isNextLocked,
                    onTap: () {
                      if (isUnlocked) {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelOptionsScreen(
                              countryId: country.id,
                              level: level,
                            ),
                          ),
                        ).then((_) {
                          if (mounted) setState(() {});
                        });
                      } else if (isNextLocked && index > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelUnlockScreen(
                              countryId: country.id,
                              targetLevel: level,
                              previousLevel: levels[index - 1],
                            ),
                          ),
                        ).then((_) {
                          if (mounted) setState(() {});
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                l10n.translate('brain_games'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _GameButton(
                      title: l10n.translate('sudoku'),
                      icon: Icons.grid_4x4_rounded,
                      color: const Color(0xFF0EA5E9), // Sky 500
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SudokuScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GameButton(
                      title: l10n.translate('chess'),
                      icon: Icons.extension_rounded,
                      color: const Color(0xFF8B5CF6), // Violet 500
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChessScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final bool isUnlocked;
  final bool isNextLocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    this.isNextLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color color = isUnlocked
        ? const Color(0xFF6366F1) // Indigo 500
        : (isNextLocked
              ? const Color(0xFFF59E0B) // Amber 500
              : const Color(0xFF94A3B8)); // Slate 400

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        borderRadius: 20,
        color: isUnlocked 
            ? color.withValues(alpha: isDark ? 0.15 : 0.1)
            : color.withValues(alpha: isDark ? 0.08 : 0.05),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: isDark ? 0.4 : 0.3)
              : color.withValues(alpha: isDark ? 0.2 : 0.15),
          width: 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                isNextLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: color.withValues(alpha: 0.6),
                size: 24,
              ),
            if (!isUnlocked) const SizedBox(height: 4),
            Text(
              level,
              style: TextStyle(
                fontSize: isUnlocked ? 32 : 20,
                fontWeight: FontWeight.w900,
                color: isUnlocked ? color : color.withValues(alpha: 0.5),
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.5,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
