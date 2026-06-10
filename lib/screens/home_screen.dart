import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../models/quiz_question.dart';
import '../providers/daily_missions_provider.dart';
import 'city_quiz_selection_screen.dart';
import 'difficulty_screen.dart';
import 'achievements_screen.dart';
import 'sudoku_screen.dart';
import 'chess_screen.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';

import 'notifications_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToDifficulty(QuizType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DifficultyScreen(quizType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    final missions = ref.watch(dailyMissionsProvider);
    final notificationStream = ref.watch(notificationsProvider);
    final pendingCount = notificationStream.maybeWhen(
      data: (notes) => notes.length,
      orElse: () => 0,
    );

    return GradientScaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'WorldIQ',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Positioned(
                      right: 0,
                      child: Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: textColor.withValues(alpha: 0.8),
                              size: 32,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (pendingCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444), // Red 500
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('daily_missions'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDailyChallengeBanner(context),
                const SizedBox(height: 16),
                SizedBox(
                  height: 125,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: missions.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final mission = missions[index];
                      Color accentColor;
                      IconData missionIcon;

                      switch (mission.type) {
                        case 'quiz':
                          accentColor = const Color(0xFF6366F1);
                          missionIcon = Icons.quiz_rounded;
                          break;
                        case 'score':
                          accentColor = const Color(0xFF10B981);
                          missionIcon = Icons.emoji_events_rounded;
                          break;
                        case 'word':
                          accentColor = const Color(0xFFF59E0B);
                          missionIcon = Icons.menu_book_rounded;
                          break;
                        default:
                          accentColor = const Color(0xFF6366F1);
                          missionIcon = Icons.task_alt_rounded;
                      }

                      return Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 16),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 24,
                          color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                          border: Border.all(
                            color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                            width: 1.5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      missionIcon,
                                      color: accentColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.translate(mission.title).replaceAll('{goal}', mission.goal.toString()),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: textColor,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${mission.currentProgress} / ${mission.goal}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  if (mission.isCompleted)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 20,
                                    )
                                  else
                                    Text(
                                      '+${mission.rewardXp} XP',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: mission.currentProgress / mission.goal,
                                  minHeight: 6,
                                  backgroundColor: textColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    mission.isCompleted
                                        ? const Color(0xFF10B981)
                                        : accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.translate('game_modes'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05,
                  children: [
                    _ModeButton(
                      title: l10n.translate('flag_quiz'),
                      icon: Icons.flag_rounded,
                      color: const Color(0xFF6366F1), // Indigo 500
                      onTap: () =>
                          _navigateToDifficulty(QuizType.flagToCountry),
                    ),
                    _ModeButton(
                      title: l10n.translate('continent_quiz'),
                      icon: Icons.public_rounded,
                      color: const Color(0xFF10B981), // Emerald 500
                      onTap: () =>
                          _navigateToDifficulty(QuizType.countryToContinent),
                    ),
                    _ModeButton(
                      title: l10n.translate('city_quiz'),
                      icon: Icons.location_city_rounded,
                      color: const Color(0xFFF59E0B), // Amber 500
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CityQuizSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    _ModeButton(
                      title: l10n.translate('achievements'),
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFFEC4899), // Pink 500
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        );
                      },
                    ),
                    _ModeButton(
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
                    _ModeButton(
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
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeBanner(BuildContext context) {
    final challengeAsync = ref.watch(dailyChallengeProvider);
    final isCompletedAsync = ref.watch(isDailyCompletedProvider);
    final l10n = AppLocalizations.of(context)!;

    return challengeAsync.when(
      data: (challenge) {
        final isCompleted = isCompletedAsync.value ?? false;

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child!,
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('daily_challenge_label').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? l10n.translate('daily_challenge_done_msg')
                          : (challenge['title'] as String? ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                IconButton.filled(
                  onPressed: () {
                    _navigateToDifficulty(QuizType.flagToCountry);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                )
              else
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 32,
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _ModeButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(20),
          color: widget.color.withValues(alpha: isDark ? 0.08 : 0.04),
          border: Border.all(
            color: widget.color.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(widget.icon, color: widget.color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
