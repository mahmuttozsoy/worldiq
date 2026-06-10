import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/achievements_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

final otherUserAchievementsProvider =
    FutureProvider.family<List<String>, String>((ref, uid) async {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final list = data['unlockedAchievements'] as List<dynamic>?;
        return list?.map((e) => e.toString()).toList() ?? [];
      }
      return [];
    });

class AchievementsScreen extends ConsumerWidget {
  final String? userId;
  const AchievementsScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMe = userId == null || userId == currentUid;

    final achievementsAsync = isMe
        ? AsyncValue.data(ref.watch(achievementsProvider))
        : ref.watch(otherUserAchievementsProvider(userId!)).whenData((
            unlockedIds,
          ) {
            return defaultAchievements.map((ach) {
              return ach.copyWith(isUnlocked: unlockedIds.contains(ach.id));
            }).toList();
          });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A); // Slate 900
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569); // Slate 600

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('achievements'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          final totalCount = achievements.length;
          final progressPercent = totalCount > 0 ? unlockedCount / totalCount : 0.0;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: achievements.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 32, top: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF6366F1)).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$unlockedCount / $totalCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final ach = achievements[index - 1];
            final accentColor = ach.isUnlocked
                ? const Color(0xFF6366F1) // Indigo 500
                : const Color(0xFF94A3B8); // Slate 400

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                borderRadius: 28,
                padding: const EdgeInsets.all(18),
                color: ach.isUnlocked
                    ? accentColor.withValues(alpha: isDark ? 0.08 : 0.04)
                    : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
                border: Border.all(
                  color: ach.isUnlocked
                      ? accentColor.withValues(alpha: isDark ? 0.4 : 0.25)
                      : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  width: 1.5,
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ach.isUnlocked
                            ? accentColor.withValues(alpha: 0.1)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: ach.isUnlocked ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ach.icon,
                        style: TextStyle(
                          fontSize: 34,
                          color: ach.isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ach.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: ach.isUnlocked ? textColor : textColor.withValues(alpha: 0.4),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              if (ach.isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'UNLOCKED',
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ach.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: ach.isUnlocked ? secondaryTextColor : secondaryTextColor.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!ach.isUnlocked) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: textColor.withValues(alpha: 0.15),
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '${l10n.translate('error')}: $e',
            style: TextStyle(color: textColor.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}
