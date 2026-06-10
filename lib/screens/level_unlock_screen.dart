import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/vocab_quiz_provider.dart';
import 'vocab_quiz_screen.dart';

class LevelUnlockScreen extends ConsumerWidget {
  final String countryId;
  final String targetLevel;
  final String previousLevel;

  const LevelUnlockScreen({
    super.key,
    required this.countryId,
    required this.targetLevel,
    required this.previousLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Center(
                child: Hero(
                  tag: 'unlock_$targetLevel',
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.orangeAccent.withValues(alpha: 0.1) : const Color(0xFFFFF7ED), // Orange 50
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5), // Amber 500
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_open_rounded,
                      size: 64,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('unlock_challenge_title').replaceAll('{level}', targetLevel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('unlock_challenge_desc').replaceAll('{prev}', previousLevel),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              _RequirementCard(
                icon: Icons.quiz_rounded,
                title: l10n.translate('unlock_requirement_questions'),
                subtitle: l10n.translate('unlock_requirement_questions_desc'),
                accent: const Color(0xFF6366F1), // Indigo
              ),
              const SizedBox(height: 12),
              _RequirementCard(
                icon: Icons.verified_rounded,
                title: l10n.translate('unlock_requirement_success_label'),
                subtitle: l10n.translate('unlock_requirement_success_desc'),
                accent: const Color(0xFF10B981), // Emerald
              ),
              const SizedBox(height: 12),
              _RequirementCard(
                icon: Icons.favorite_rounded,
                title: l10n.translate('unlock_requirement_lives'),
                subtitle: l10n.translate('unlock_requirement_lives_desc'),
                accent: const Color(0xFFF43F5E), // Rose
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () async {
                  ref
                      .read(vocabQuizProvider.notifier)
                      .startQuiz(
                        countryId,
                        previousLevel,
                        isUnlockTest: true,
                        unlockTargetLevel: targetLevel,
                        questionCount: 75,
                      );
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const VocabQuizScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B), // Amber 500
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.translate('start_challenge_btn'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.translate('not_ready_btn'),
                  style: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _RequirementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GlassContainer(
      borderRadius: 24,
      color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 20),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
