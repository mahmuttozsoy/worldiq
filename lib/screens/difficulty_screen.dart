import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_question.dart';
import '../providers/quiz_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import 'quiz_screen.dart';

class DifficultyScreen extends ConsumerWidget {
  final QuizType quizType;

  const DifficultyScreen({super.key, required this.quizType});

  void _startGame(
    BuildContext context,
    WidgetRef ref,
    QuizDifficulty difficulty,
  ) {
    ref.read(quizProvider.notifier).startQuiz(quizType, difficulty);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    IconData headerIcon;
    Color headerColor;
    String quizTitleKey;

    switch (quizType) {
      case QuizType.flagToCountry:
        headerIcon = Icons.flag_rounded;
        headerColor = const Color(0xFF10B981);
        quizTitleKey = 'flag_quiz';
        break;
      case QuizType.countryToContinent:
        headerIcon = Icons.public_rounded;
        headerColor = const Color(0xFF6366F1);
        quizTitleKey = 'continent_quiz';
        break;
      case QuizType.capitalToCountry:
        headerIcon = Icons.location_city_rounded;
        headerColor = const Color(0xFFF59E0B);
        quizTitleKey = 'city_quiz';
        break;
      case QuizType.countryToCapital:
        headerIcon = Icons.account_balance_rounded;
        headerColor = const Color(0xFF8B5CF6);
        quizTitleKey = 'city_quiz';
        break;
      case QuizType.plateToCity:
      case QuizType.cityToPlate:
        headerIcon = Icons.directions_car_rounded;
        headerColor = const Color(0xFFF59E0B);
        quizTitleKey = 'tr_plate_quiz';
        break;
      case QuizType.cityToRegion:
      case QuizType.regionToCity:
        headerIcon = Icons.map_rounded;
        headerColor = const Color(0xFF10B981);
        quizTitleKey = 'tr_region_quiz';
        break;
    }

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [headerColor, headerColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: headerColor.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(headerIcon, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'WorldIQ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate(quizTitleKey).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('difficulty_lobby_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 34),
              _DifficultyButton(
                title: l10n.translate('beginner'),
                subtitle: l10n.translate('easy_desc'),
                icon: Icons.sentiment_satisfied_alt,
                color: const Color(0xFF10B981),
                onTap: () => _startGame(context, ref, QuizDifficulty.easy),
              ),
              const SizedBox(height: 14),
              _DifficultyButton(
                title: l10n.translate('pro'),
                subtitle: l10n.translate('medium_desc'),
                icon: Icons.sentiment_neutral,
                color: const Color(0xFFF59E0B),
                onTap: () => _startGame(context, ref, QuizDifficulty.medium),
              ),
              const SizedBox(height: 14),
              _DifficultyButton(
                title: l10n.translate('champion'),
                subtitle: l10n.translate('hard_desc'),
                icon: Icons.sentiment_very_dissatisfied,
                color: const Color(0xFFEF4444),
                onTap: () => _startGame(context, ref, QuizDifficulty.hard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
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
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.5,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
