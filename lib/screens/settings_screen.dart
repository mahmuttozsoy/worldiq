import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/user_progress_provider.dart';
import '../providers/shared_prefs_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final progress = ref.watch(userProgressProvider);
    final notifier = ref.read(userProgressProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('settings'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: l10n.translate('appearance')),
            const SizedBox(height: 16),
            GlassContainer(
              borderRadius: 24,
              color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    title: l10n.translate('dark_mode'),
                    subtitle: l10n.translate('dark_mode_desc'),
                    value: themeMode == ThemeMode.dark,
                    icon: Icons.dark_mode_outlined,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SectionTitle(title: l10n.translate('privacy_social')),
            const SizedBox(height: 16),
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    title: l10n.translate('privacy'),
                    subtitle: l10n.translate('privacy_desc'),
                    value: progress.isPrivate,
                    icon: Icons.lock_outline_rounded,
                    onChanged: (val) {
                      notifier.updatePrivacy(val);
                    },
                  ),
                  const _ThemeDivider(),
                  _SettingsSwitchTile(
                    title: l10n.translate('notifications_active'),
                    subtitle: l10n.translate('notifications_desc'),
                    value: notificationsEnabled,
                    icon: Icons.notifications_active_outlined,
                    onChanged: (val) {
                      prefs.setBool('notificationsEnabled', val);
                      setState(() {});
                    },
                  ),
                  const _ThemeDivider(),
                  _SettingsActionTile(
                    title: l10n.translate('blocked_users'),
                    icon: Icons.block_flipped,
                    onTap: () => _showBlockedUsersDialog(context, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SectionTitle(title: l10n.translate('account')),
            const SizedBox(height: 16),
            GlassContainer(
              borderRadius: 24,
              color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _SettingsActionTile(
                    title: l10n.translate('change_password'),
                    icon: Icons.password_rounded,
                    onTap: () => _showChangePasswordDialog(context, l10n),
                  ),
                  const _ThemeDivider(),
                  _SettingsActionTile(
                    title: l10n.translate('logout'),
                    icon: Icons.logout_rounded,
                    onTap: () => _showLogoutDialog(context, l10n),
                    textColor: const Color(0xFFEF4444), // Red 500
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SectionTitle(title: l10n.translate('support')),
            const SizedBox(height: 16),
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _SettingsActionTile(
                    title: l10n.translate('help_support'),
                    icon: Icons.help_outline_rounded,
                    onTap: () {},
                  ),
                  const _ThemeDivider(),
                  _SettingsActionTile(
                    title: l10n.translate('about'),
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showAboutDialog(context, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.translate('logout_confirm_title'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Text(
          l10n.translate('logout_confirm_desc'),
          style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('cancel'),
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(l10n.translate('logout'), style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'WorldIQ',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.translate('version_label')} 1.0.0',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 WorldIQ Ekibi',
              style: TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.translate('about_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.translate('change_password'),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Şifre sıfırlama bağlantısı aşağıdaki adrese gönderilecek:',
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
              ),
              child: Text(
                email.isNotEmpty ? email : 'E-posta bulunamadı',
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel'), style: TextStyle(color: secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(child: Text('Password reset email sent!')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Send', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.translate('blocked_users'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded, color: secondaryTextColor.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text(
              'Engellediğiniz kullanıcı bulunmuyor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6366F1), // Indigo primary
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? const Color(0xFF6366F1)).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: textColor ?? const Color(0xFF6366F1), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? defaultTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: secondaryTextColor.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}

class _ThemeDivider extends StatelessWidget {
  const _ThemeDivider();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
      indent: 60,
      endIndent: 20,
    );
  }
}
