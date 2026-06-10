import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import 'chess_screen.dart';
import 'package:world_iq/services/firebase_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'package:world_iq/providers/l10n_extension.dart';

class MultiplayerWaitingScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String gameType;
  final String difficulty;
  final bool isHost;

  const MultiplayerWaitingScreen({
    super.key,
    required this.sessionId,
    required this.gameType,
    required this.difficulty,
    this.isHost = true,
  });

  @override
  ConsumerState<MultiplayerWaitingScreen> createState() => _MultiplayerWaitingScreenState();
}

class _MultiplayerWaitingScreenState extends ConsumerState<MultiplayerWaitingScreen> {
  int _secondsLeft = 60;
  Timer? _timer;
  StreamSubscription? _sessionSub;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _listenToSession();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _cancelSession(context.l10n.translate('invite_timed_out'));
      }
    });
  }

  void _listenToSession() {
    _sessionSub = ref.read(firebaseServiceProvider).listenToGameSession(widget.sessionId).listen((data) {
      if (data != null && data['status'] == 'joined') {
        _startGame();
      }
    });
  }

  void _startGame() {
    _timer?.cancel();
    _sessionSub?.cancel();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChessScreen(
            initialDifficulty: widget.difficulty,
            sessionId: widget.sessionId,
            isHost: widget.isHost,
          ),
        ),
      );
    }
  }

  void _cancelSession([String? message]) async {
    _timer?.cancel();
    _sessionSub?.cancel();
    await ref.read(firebaseServiceProvider).cancelGameSession(widget.sessionId);
    if (mounted) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final accentColor = const Color(0xFF6366F1);

    return GradientScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassContainer(
            borderRadius: 32,
            color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: accentColor,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.translate('chess_invite_waiting'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor, 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    l10n.translate('difficulty_label').replaceAll('{difficulty}', widget.difficulty),
                    style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 48),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _secondsLeft / 60,
                        color: _secondsLeft < 10 ? const Color(0xFFEF4444) : accentColor,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$_secondsLeft',
                      style: TextStyle(
                        color: _secondsLeft < 10 ? const Color(0xFFEF4444) : textColor, 
                        fontSize: 36, 
                        fontWeight: FontWeight.w900
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('seconds_left_label'), 
                  style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)
                ),
                const SizedBox(height: 48),
                Text(
                  l10n.translate('waiting_for_opponent'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _cancelSession(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFEF4444).withValues(alpha: 0.15) : const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 1.5),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.translate('cancel_invite'), 
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
