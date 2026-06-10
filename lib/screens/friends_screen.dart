import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import 'profile_screen.dart';
import 'multiplayer_waiting_screen.dart';
import 'package:world_iq/services/firebase_service.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';

final friendsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).getFollowingStream();
});

final outgoingRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.watch(firebaseServiceProvider).getOutgoingRequestsStream();
});

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final accentColor = const Color(0xFF6366F1);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('friends_title'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: textColor),
            onPressed: () => _showAddFriendDialog(context, ref, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: 20,
              color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.translate('search_friends'),
                  hintStyle: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: secondaryTextColor.withValues(alpha: 0.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: secondaryTextColor.withValues(alpha: 0.5), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: friendsAsync.when(
              data: (friends) {
                final filtered = _searchQuery.isEmpty
                    ? friends
                    : friends.where((f) {
                        final name = (f['name'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          color: textColor.withValues(alpha: 0.1),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Eşleşen arkadaş bulunamadı.'
                              : l10n.translate('no_friends'),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final friend = filtered[index];
                    final isOnline = friend['isOnline'] == true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileScreen(userId: friend['uid']),
                          ),
                        ),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 24,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: textColor.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      avatarsData
                                          .firstWhere(
                                            (a) =>
                                                a.id ==
                                                friend['selectedAvatarId'],
                                            orElse: () => avatarsData[0],
                                          )
                                          .imageUrl,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? const Color(0xFF10B981)
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend['name'] ?? 'İsimsiz',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Text(
                                      isOnline
                                          ? l10n.translate('online')
                                          : l10n.translate('offline'),
                                      style: TextStyle(
                                        color: isOnline
                                            ? const Color(0xFF10B981)
                                            : secondaryTextColor.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOnline)
                                IconButton.filled(
                                  onPressed: () => _showInviteDialog(
                                    context,
                                    ref,
                                    friend['name'] ?? '',
                                    friend['uid'],
                                    l10n,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: accentColor.withValues(
                                      alpha: isDark ? 0.1 : 0.08,
                                    ),
                                    foregroundColor: accentColor,
                                  ),
                                  icon: const Icon(
                                    Icons.videogame_asset_rounded,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  l10n.translate('error'),
                  style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    WidgetRef ref,
    String name,
    String friendId,
    AppLocalizations l10n,
  ) {
    List<String> difficulties = [
      l10n.translate('beginner'),
      l10n.translate('pro'),
      l10n.translate('champion'),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          '$name ${l10n.translate('invite_to_chess')}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('select_difficulty'),
              style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ...difficulties.map(
              (d) => ListTile(
                title: Text(d, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6366F1),
                ),
                onTap: () async {
                  // Show loading feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('loading_invite')),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  final firebase = ref.read(firebaseServiceProvider);
                  try {
                    final sessionId = await firebase.createGameSession(
                      friendId,
                      'Satranç',
                      d,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context); // Close dialog

                    if (sessionId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiplayerWaitingScreen(
                            sessionId: sessionId,
                            gameType: 'Satranç',
                            difficulty: d,
                          ),
                        ),
                      );
                    } else {
                      throw Exception(l10n.translate('session_error'));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${l10n.translate('error')}: ${e.toString()}',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('cancel'),
              style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            l10n.translate('add_friend'),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: l10n.translate('search_username'),
                    hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                      onPressed: () async {
                        setState(() => isSearching = true);
                        final results = await ref
                            .read(firebaseServiceProvider)
                            .searchUsers(searchController.text);
                        setState(() {
                          searchResults = results;
                          isSearching = false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isSearching)
                  const CircularProgressIndicator()
                else if (searchResults.isEmpty &&
                    searchController.text.isNotEmpty)
                  Text(
                    l10n.translate('user_not_found'),
                    style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.6)),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        final avatarEmoji = avatarsData
                            .firstWhere(
                              (a) => a.id == user['selectedAvatarId'],
                              orElse: () => avatarsData[0],
                            )
                            .imageUrl;

                        final outgoingRequests =
                            ref.watch(outgoingRequestsProvider).value ?? [];
                        final isAlreadyRequested = outgoingRequests.any(
                          (req) => req['toId'] == user['uid'],
                        );

                        return ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(userId: user['uid']),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              avatarEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          title: Text(
                            user['name'] ??
                                user['username'] ??
                                l10n.translate('user_not_found'),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${l10n.translate('level')} ${user['level'] ?? 1}',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          trailing: isAlreadyRequested
                              ? Text(
                                  l10n.translate('request_sent'),
                                  style: TextStyle(
                                    color: secondaryTextColor.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Color(0xFF6366F1),
                                  ),
                                  onPressed: () async {
                                    await ref
                                        .read(firebaseServiceProvider)
                                        .sendFriendRequest(user);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.translate(
                                            'friend_request_sent_msg',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.translate('close'),
                style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
