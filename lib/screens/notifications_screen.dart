import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';

import 'chess_screen.dart';
import 'package:world_iq/services/firebase_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('notifications'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: notificationsAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: secondaryTextColor.withValues(alpha: 0.2),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('no_notifications_msg'),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _NotificationItem(note: note, l10n: l10n);
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
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final Map<String, dynamic> note;
  final AppLocalizations l10n;
  const _NotificationItem({required this.note, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRequest = note['type'] == 'friend_request';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final accentColor = const Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRequest
                        ? Icons.person_add_rounded
                        : Icons.sports_esports_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRequest
                        ? l10n.translate('friend_request')
                        : l10n.translate('game_invite'),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Text(
                  _formatTimestamp(note['timestamp'], l10n),
                  style: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isRequest
                  ? '${note['fromName']} ${l10n.translate('friend_request_msg')}'
                  : '${note['fromName']} ${l10n.translate('game_invite_msg')}',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (isRequest)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(firebaseServiceProvider)
                          .rejectFriendRequest(note['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.translate('reject'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(firebaseServiceProvider)
                          .acceptFriendRequest(note),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(l10n.translate('accept'), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(firebaseServiceProvider)
                          .markNotificationAsSeen(note['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.translate('reject'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final sessionId = note['sessionId'];
                        final difficulty = note['difficulty'];

                        if (sessionId != null) {
                          await ref
                              .read(firebaseServiceProvider)
                              .joinGameSession(sessionId);
                        }

                        await ref
                            .read(firebaseServiceProvider)
                            .markNotificationAsSeen(note['id']);

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChessScreen(
                                initialDifficulty: difficulty,
                                sessionId: sessionId,
                                isHost: false,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Emerald 500
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(l10n.translate('accept'), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp, AppLocalizations l10n) {
    if (timestamp == null) return '';
    return l10n.translate('just_now');
  }
}
