import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';

class AvatarSelectionScreen extends ConsumerWidget {
  const AvatarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final notifier = ref.read(userProgressProvider.notifier);
    final currentLeague = notifier.getLeague();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Avatar Seç',
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 24,
          childAspectRatio: 0.8,
        ),
        itemCount: avatarsData.length,
        itemBuilder: (context, index) {
          final avatar = avatarsData[index];
          final isUnlocked = avatar.isUnlocked(progress.score, currentLeague);
          final isSelected = avatar.id == progress.selectedAvatarId;

          return GestureDetector(
            onTap: isUnlocked ? () {
              notifier.updateAvatar(avatar.id);
              Navigator.pop(context);
            } : null,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                        ? const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.1) 
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)), // Slate 50
                      border: Border.all(
                        color: isSelected 
                          ? const Color(0xFF6366F1) 
                          : (isUnlocked 
                              ? (isDark ? Colors.white24 : const Color(0xFFE2E8F0)) 
                              : (isDark ? Colors.white10 : const Color(0xFFF1F5F9))), // Slate 100
                        width: 2.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          avatar.imageUrl,
                          style: TextStyle(
                            fontSize: 44, 
                            color: isUnlocked 
                              ? null 
                              : textColor.withValues(alpha: 0.1)
                          ),
                        ),
                        if (!isUnlocked)
                          Icon(
                            Icons.lock_rounded, 
                            color: textColor.withValues(alpha: 0.3), 
                            size: 24
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  avatar.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnlocked ? textColor : secondaryTextColor,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 2),
                  Text(
                    avatar.requiredLeague != null ? avatar.requiredLeague! : '${avatar.requiredScore} XP',
                    style: const TextStyle(
                      fontSize: 10, 
                      color: Color(0xFFD97706), // Amber 600
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
