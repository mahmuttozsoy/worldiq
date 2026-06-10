import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../models/avatar.dart';
import '../models/user_progress.dart';
import 'achievements_screen.dart';
import 'avatar_selection_screen.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'social_list_screen.dart';
import 'package:world_iq/services/firebase_service.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final targetUid = userId ?? currentUid;
    final isMe = targetUid == currentUid;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    if (isMe) {
      final progress = ref.watch(userProgressProvider);
      return _buildProfileContent(
        context,
        ref,
        progress,
        true,
        l10n,
        targetUid,
      );
    } else {
      final otherProgressAsync = ref.watch(
        otherUserProgressProvider(targetUid),
      );
      return otherProgressAsync.when(
        data: (progress) {
          if (progress == null) {
            return GradientScaffold(
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: Center(
                child: Text(
                  l10n.translate('user_not_found'),
                  style: TextStyle(color: textColor),
                ),
              ),
            );
          }
          return _buildProfileContent(
            context,
            ref,
            progress,
            false,
            l10n,
            targetUid,
          );
        },
        loading: () => const GradientScaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => GradientScaffold(
          body: Center(
            child: Text(
              '${l10n.translate('error')}: $e',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserProgress progress,
    bool isMe,
    AppLocalizations l10n,
    String targetUid,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final followersCount =
        ref.watch(followersCountProvider(targetUid)).value ?? 0;
    final followingCount =
        ref.watch(followingCountProvider(targetUid)).value ?? 0;
    final isFollowing = !isMe
        ? (ref.watch(followStatusProvider(targetUid)).value ?? false)
        : false;

    final league = _calculateLeague(progress.score, l10n);
    final avatar = avatarsData.firstWhere(
      (a) => a.id == progress.selectedAvatarId,
      orElse: () => avatarsData[0],
    );

    final showContent = !progress.isPrivate || isMe || isFollowing;

    return GradientScaffold(
      appBar: !isMe
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                progress.name,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              iconTheme: IconThemeData(color: textColor),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMe) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Balance for settings icon
                    Text(
                      l10n.translate('profile'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_rounded,
                        color: secondaryTextColor,
                        size: 26,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 32,
                child: Column(
                  children: [
                    Hero(
                      tag: 'avatar_$targetUid',
                      child: GestureDetector(
                        onTap: isMe
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AvatarSelectionScreen(),
                                ),
                              )
                            : null,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: progress.isOnline
                                      ? const Color(0xFF10B981)
                                      : secondaryTextColor.withValues(alpha: 0.2),
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 54,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.05,
                                ),
                                child: Text(
                                  avatar.imageUrl,
                                  style: const TextStyle(fontSize: 54),
                                ),
                              ),
                            ),
                            if (isMe)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: isMe
                          ? () =>
                                _showNameEditDialog(context, ref, progress.name)
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            progress.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: textColor.withValues(alpha: 0.3),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '$league ${l10n.translate('league_label')}',
                        style: const TextStyle(
                          color: Color(0xFFB45309), // Amber 700
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: textColor.withValues(alpha: 0.05)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialStatWidget(
                          label: l10n.translate('followers'),
                          value: '$followersCount',
                          textColor: textColor,
                          onTap: showContent
                              ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SocialListScreen(
                                      title: l10n.translate('followers'),
                                      isFollowers: true,
                                      userId: targetUid,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: textColor.withValues(alpha: 0.05),
                        ),
                        _SocialStatWidget(
                          label: l10n.translate('following'),
                          value: '$followingCount',
                          textColor: textColor,
                          onTap: showContent
                              ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SocialListScreen(
                                      title: l10n.translate('following'),
                                      isFollowers: false,
                                      userId: targetUid,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!isMe) ...[
                ElevatedButton(
                  onPressed: () => _handleFollowAction(
                    ref,
                    targetUid,
                    isFollowing,
                    progress,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? textColor.withValues(alpha: 0.05)
                        : const Color(0xFF6366F1),
                    foregroundColor: isFollowing ? textColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    isFollowing
                        ? l10n.translate('unfollow')
                        : l10n.translate('follow'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (!showContent)
                _buildPrivateAccountMessage(l10n, textColor)
              else ...[
                _buildSectionHeader(l10n.translate('statistics'), textColor),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                  children: [
                    _ProfileStatCard(
                      label: l10n.translate('streak'),
                      value: '${progress.streak}',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orangeAccent,
                    ),
                    _ProfileStatCard(
                      label: l10n.translate('level'),
                      value: '${progress.level}',
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFF6366F1), // Indigo
                    ),
                    _ProfileStatCard(
                      label: l10n.translate('score'),
                      value: '${progress.score}',
                      icon: Icons.stars_rounded,
                      color: Colors.amber,
                    ),
                  ],
                ),
                if (isMe) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    l10n.translate('account_info'),
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    borderRadius: 24,
                    child: Column(
                      children: [
                        _AccountInfoRow(
                          label: l10n.translate('privacy'),
                          value: progress.isPrivate
                              ? l10n.translate('done')
                              : l10n.translate('go'),
                          icon: progress.isPrivate
                              ? Icons.lock_rounded
                              : Icons.lock_open_rounded,
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: progress.isPrivate,
                              onChanged: (val) {
                                ref
                                    .read(userProgressProvider.notifier)
                                    .updatePrivacy(val);
                              },
                              activeColor: const Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        Divider(
                          color: textColor.withValues(alpha: 0.05),
                          height: 1,
                        ),
                        _AccountInfoRow(
                          label: l10n.translate('username'),
                          value: progress.name,
                          icon: Icons.alternate_email_rounded,
                          onTap: () =>
                              _showNameEditDialog(context, ref, progress.name),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.translate('match_history'), textColor),
                const SizedBox(height: 16),
                _buildMatchHistory(ref, targetUid, l10n, textColor),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  isMe
                      ? l10n.translate('menu')
                      : l10n.translate('achievements'),
                  textColor,
                ),
                const SizedBox(height: 16),
                if (isMe) ...[
                  _MenuTile(
                    icon: Icons.emoji_events_outlined,
                    title: l10n.translate('achievements'),
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.translate('help_support'),
                    color: const Color(0xFF6366F1), // Indigo
                    onTap: () => _showSupportDialog(context, l10n),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await AuthService().logout();
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      label: Text(
                        l10n.translate('logout'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else
                  _MenuTile(
                    icon: Icons.emoji_events_outlined,
                    title: l10n.translate('view_achievements'),
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AchievementsScreen(userId: targetUid),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildPrivateAccountMessage(AppLocalizations l10n, Color textColor) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.lock_outline_rounded,
          color: textColor.withValues(alpha: 0.1),
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.translate('private_account_title'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('private_account_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchHistory(
    WidgetRef ref,
    String uid,
    AppLocalizations l10n,
    Color textColor,
  ) {
    final historyAsync = ref.watch(matchHistoryProvider(uid));

    return historyAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Text(
              l10n.translate('no_match_history'),
              style: TextStyle(color: textColor.withValues(alpha: 0.2)),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final isWin = match['isWin'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                borderRadius: 16,
                child: Row(
                  children: [
                    Icon(
                      isWin ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isWin ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match['gameType'] ?? l10n.translate('game'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          isWin
                              ? l10n.translate('win')
                              : l10n.translate('loss'),
                          style: TextStyle(
                            color: isWin
                                ? const Color(0xFF10B981).withValues(alpha: 0.7)
                                : const Color(0xFFEF4444).withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (match['xpGained'] > 0)
                      Text(
                        '+${match['xpGained']} XP',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        '${l10n.translate('error')}: $e',
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  void _handleFollowAction(
    WidgetRef ref,
    String targetUid,
    bool isFollowing,
    UserProgress progress,
  ) async {
    final firebase = ref.read(firebaseServiceProvider);
    if (isFollowing) {
      await firebase.unfollowUser(targetUid);
    } else {
      await firebase.followUser({
        'uid': targetUid,
        'name': progress.name,
        'score': progress.score,
        'level': progress.level,
        'selectedAvatarId': progress.selectedAvatarId,
      });
    }
  }

  String _calculateLeague(int score, AppLocalizations l10n) {
    if (score >= 6000) return l10n.translate('league_diamond');
    if (score >= 3000) return l10n.translate('league_platinum');
    if (score >= 1500) return l10n.translate('league_gold');
    if (score >= 500) return l10n.translate('league_silver');
    return l10n.translate('league_bronze');
  }

  void _showNameEditDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          l10n.translate('edit_name'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: l10n.translate('new_name'),
            labelStyle: TextStyle(color: secondaryTextColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('cancel'),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(userProgressProvider.notifier)
                    .updateName(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.translate('save'),
              style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.translate('help_support'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSupportOption(
                    context,
                    icon: Icons.alternate_email_rounded,
                    title: 'E-posta Desteği',
                    subtitle: 'destek@worldiq.com',
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'destek@worldiq.com'));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('E-posta adresi kopyalandı!'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF6366F1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSupportOption(
                    context,
                    icon: Icons.rate_review_rounded,
                    title: 'Geri Bildirim',
                    subtitle: 'Uygulamayı değerlendir',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Değerlendirme için teşekkürler!'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('close'),
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1.5,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withValues(alpha: 0.2),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AccountInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor.withValues(alpha: 0.7), size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: textColor.withValues(alpha: 0.2),
                )
              : null),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(12),
      color: color.withValues(alpha: isDark ? 0.05 : 0.03),
      border: Border.all(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        width: 1.5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.4),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          borderRadius: 24,
          color: color.withValues(alpha: isDark ? 0.08 : 0.04),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            width: 1.5,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.2),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialStatWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final VoidCallback? onTap;

  const _SocialStatWidget({
    required this.label,
    required this.value,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
