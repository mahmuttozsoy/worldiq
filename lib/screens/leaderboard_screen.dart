import 'package:firebase_auth/firebase_auth.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../models/avatar.dart';
import '../providers/locale_provider.dart';

import 'profile_screen.dart';
import 'package:world_iq/services/firebase_service.dart';

String _safeLeagueLabel(String keyOrLabel, AppLocalizations l10n) {
  if (!keyOrLabel.startsWith('league_')) {
    return keyOrLabel;
  }

  final translated = l10n.translate(keyOrLabel);
  if (translated != keyOrLabel) {
    return translated;
  }

  return switch (keyOrLabel) {
    'league_bronze' => 'Bronze',
    'league_silver' => 'Silver',
    'league_gold' => 'Gold',
    'league_platinum' => 'Platinum',
    'league_diamond' => 'Diamond',
    _ => keyOrLabel.replaceAll('league_', '').replaceAll('_', ' '),
  };
}

({int? minInclusive, int? maxExclusive}) leaderboardFirestoreBounds(
  String selectedLeagueLabel,
  AppLocalizations l10n,
) {
  bool isLeague(String key) {
    final t = l10n.translate(key);
    return selectedLeagueLabel == t || selectedLeagueLabel == key;
  }

  if (isLeague('league_diamond')) {
    return (minInclusive: 6000, maxExclusive: null);
  }
  if (isLeague('league_platinum')) {
    return (minInclusive: 3000, maxExclusive: 6000);
  }
  if (isLeague('league_gold')) {
    return (minInclusive: 1500, maxExclusive: 3000);
  }
  if (isLeague('league_silver')) {
    return (minInclusive: 500, maxExclusive: 1500);
  }
  return (minInclusive: null, maxExclusive: 500);
}

final realLeaderboardProvider = StreamProvider.autoDispose<List<LeaderboardUser>>((
  ref,
) {
  final firebase = ref.watch(firebaseServiceProvider);
  final selectedLeague = ref.watch(selectedLeagueProvider);
  
  ({int? minInclusive, int? maxExclusive}) bounds;
  
  if (selectedLeague == 'league_diamond') {
    bounds = (minInclusive: 6000, maxExclusive: null);
  } else if (selectedLeague == 'league_platinum') {
    bounds = (minInclusive: 3000, maxExclusive: 6000);
  } else if (selectedLeague == 'league_gold') {
    bounds = (minInclusive: 1500, maxExclusive: 3000);
  } else if (selectedLeague == 'league_silver') {
    bounds = (minInclusive: 500, maxExclusive: 1500);
  } else {
    bounds = (minInclusive: null, maxExclusive: 500);
  }

  return firebase.getLeaderboardStream().map((firestoreAll) {
    final filtered = firestoreAll.where((data) {
      final score = (data['score'] ?? data['totalScore'] ?? 0) as int;
      final meetsMin =
          bounds.minInclusive == null || score >= bounds.minInclusive!;
      final meetsMax =
          bounds.maxExclusive == null || score < bounds.maxExclusive!;
      return meetsMin && meetsMax;
    }).toList();

    // Sort in-memory descending by score
    filtered.sort((a, b) {
      final scoreA = (a['score'] ?? a['totalScore'] ?? 0) as int;
      final scoreB = (b['score'] ?? b['totalScore'] ?? 0) as int;
      return scoreB.compareTo(scoreA);
    });

    return filtered.map((data) {
      try {
        return LeaderboardUser(
          uid: data['uid'],
          name: data['name'] ?? data['username'] ?? 'Anonim',
          score: data['score'] ?? data['totalScore'] ?? 0,
          level: (data['level'] is int) ? data['level'] : 1,
          avatar: avatarsData
              .firstWhere(
                (a) => a.id == data['selectedAvatarId'],
                orElse: () => avatarsData[0],
              )
              .imageUrl,
        );
      } catch (e) {
        return LeaderboardUser(
          uid: data['uid'],
          name: 'Invalid Data',
          score: 0,
          level: 1,
          avatar: '❓',
        );
      }
    }).toList();
  });
});

class LeaderboardUser {
  final String? uid;
  final String name;
  final int score;
  final int level;
  final String avatar;
  final bool isCurrentUser;

  LeaderboardUser({
    this.uid,
    required this.name,
    required this.score,
    required this.level,
    required this.avatar,
    this.isCurrentUser = false,
  });

  LeaderboardUser copyWith({
    String? uid,
    String? name,
    int? score,
    int? level,
    String? avatar,
    bool? isCurrentUser,
  }) {
    return LeaderboardUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      score: score ?? this.score,
      level: level ?? this.level,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class SelectedLeagueNotifier extends Notifier<String> {
  @override
  String build() {
    // İlk başta kullanıcının kendi ligini döndür.
    // Skor değiştiğinde veya dil değiştiğinde lig adının güncellenmesi için her iki sağlayıcıyı da izliyoruz.
    final score = ref.watch(userProgressProvider.select((p) => p.score));
    ref.watch(localeProvider);
    return _calculateLeague(score);
  }

  void setLeague(String league) {
    state = league;
  }

  String _calculateLeague(int score) {
    if (score >= 6000) return 'league_diamond';
    if (score >= 3000) return 'league_platinum';
    if (score >= 1500) return 'league_gold';
    if (score >= 500) return 'league_silver';
    return 'league_bronze';
  }
}

final selectedLeagueProvider = NotifierProvider<SelectedLeagueNotifier, String>(
  () {
    return SelectedLeagueNotifier();
  },
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realLeaderboard = ref.watch(realLeaderboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final selectedLeague = ref.watch(selectedLeagueProvider);
    final progress = ref.watch(userProgressProvider);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('leaderboard_title'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          _LeagueHeader(
            selectedLeague: selectedLeague,
            onLeagueChanged: (league) =>
                ref.read(selectedLeagueProvider.notifier).setLeague(league),
            l10n: l10n,
            textColor: textColor,
          ),
          Expanded(
            child: realLeaderboard.when(
              data: (allUsers) {
                final users = allUsers;

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: secondaryTextColor.withValues(alpha: 0.2),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_safeLeagueLabel(selectedLeague, l10n)} ${l10n.translate('league_label')} için henüz oyuncu yok.',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    final isUser = user.uid == currentUid;

                    // Eğer bu kullanıcı bizsek, yerel (anlık) veriyi kullan
                    if (isUser) {
                      user = user.copyWith(
                        name: progress.name,
                        score: progress.score,
                        level: progress.level,
                        avatar: avatarsData
                            .firstWhere(
                              (a) => a.id == progress.selectedAvatarId,
                            )
                            .imageUrl,
                        isCurrentUser: true,
                      );
                    }

                    return _LeaderboardItem(
                      rank: index + 1,
                      user: user,
                      l10n: l10n,
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: const Color(0xFF6366F1))),
              error: (e, _) => Center(
                child: Text(
                  '${l10n.translate('error')}: $e',
                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final String selectedLeague;
  final Function(String) onLeagueChanged;
  final AppLocalizations l10n;
  final Color textColor;
  const _LeagueHeader({
    required this.selectedLeague,
    required this.onLeagueChanged,
    required this.l10n,
    required this.textColor,
  });

  List<String> get leagues => [
    'league_bronze',
    'league_silver',
    'league_gold',
    'league_platinum',
    'league_diamond',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final key = leagues[index];
          final lName = _safeLeagueLabel(key, l10n);
          final isSelected = key == selectedLeague || lName == selectedLeague;
          final accentColor = const Color(0xFF6366F1); // Indigo

          return GestureDetector(
            onTap: () => onLeagueChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isSelected
                    ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
                    : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9)),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: isDark ? 0.5 : 0.3)
                      : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: isSelected
                        ? accentColor
                        : textColor.withValues(alpha: 0.15),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? textColor
                          : textColor.withValues(alpha: 0.3),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final LeaderboardUser user;
  final AppLocalizations l10n;

  const _LeaderboardItem({
    required this.rank,
    required this.user,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final accentColor = const Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: user.isCurrentUser 
            ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08) 
            : (isDark ? null : const Color(0xFFF8FAFC)),
        border: user.isCurrentUser
            ? Border.all(color: accentColor.withValues(alpha: 0.4), width: 2)
            : Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0), width: 1.5),
        child: InkWell(
          onTap: () {
            if (user.uid != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: user.uid),
                ),
              );
            }
          },
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getRankColor(rank).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    color: _getRankColor(rank),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(user.avatar, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Seviye ${user.level}',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.score}',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'IQ',
                    style: TextStyle(
                      color: accentColor.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFF59E0B); // Gold
    if (rank == 2) return const Color(0xFF94A3B8); // Silver
    if (rank == 3) return const Color(0xFFB45309); // Bronze
    return const Color(0xFF6366F1); // Indigo
  }
}
