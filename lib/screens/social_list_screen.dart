import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../models/avatar.dart';
import 'profile_screen.dart';
import 'package:world_iq/services/firebase_service.dart';

class SocialListScreen extends ConsumerWidget {
  final String title;
  final bool isFollowers;
  final String? userId;

  const SocialListScreen({
    super.key,
    required this.title,
    required this.isFollowers,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = userId ?? currentUid;
    final isMe = targetUid == currentUid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    final listAsync = isFollowers 
        ? ref.watch(followersStreamProvider(targetUid))
        : ref.watch(followingStreamProvider(targetUid));

    return GradientScaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: listAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFollowers ? Icons.people_outline_rounded : Icons.person_add_outlined,
                    color: secondaryTextColor.withValues(alpha: 0.2),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isFollowers ? 'No followers yet.' : 'No following yet.',
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
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final avatarEmoji = avatarsData.firstWhere(
                (a) => a.id == user['selectedAvatarId'],
                orElse: () => avatarsData[0],
              ).imageUrl;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                  borderRadius: 24,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => ProfileScreen(userId: user['uid']))
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(avatarEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                    title: Text(
                      user['name'] ?? 'Unnamed',
                      style: TextStyle(
                        color: textColor, 
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                    ),
                    subtitle: Text(
                      'Level ${user['level'] ?? 1}', 
                      style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600, fontSize: 13)
                    ),
                    trailing: isMe ? TextButton(
                      onPressed: () => _handleAction(context, ref, user['uid']),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        isFollowers ? 'Remove' : 'Unfollow',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ) : Icon(Icons.chevron_right_rounded, color: secondaryTextColor.withValues(alpha: 0.3)),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: const Color(0xFF6366F1))),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold))),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String targetId) async {
    final firebase = ref.read(firebaseServiceProvider);
    if (isFollowers) {
      await firebase.removeFollower(targetId);
    } else {
      await firebase.unfollowUser(targetId);
    }
  }
}
