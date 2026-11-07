import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets.dart';

class CallScreen extends StatefulWidget {
  final Person p;
  final bool video;
  const CallScreen({super.key, required this.p, required this.video});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  int _sec = 0;
  bool _connected = false;
  bool _mute = false;
  bool _speaker = true;
  late bool _cam;

  static const _games = <String, List<String>>{
    'Two truths & a lie': [
      'Tell two true things and one lie about your last holiday.',
      'Share two true and one false facts about your childhood.',
    ],
    'Would you rather': [
      'Would you rather have a beach holiday or a mountain trek?',
      'Would you rather cook together or order in every weekend?',
      'Would you rather travel to the past or the future?',
    ],
    'Quick questions': [
      "What's one tradition from your family you'd love to keep?",
      'What does a perfect Sunday look like to you?',
      "What's the best meal you've ever had?",
    ],
  };

  @override
  void initState() {
    super.initState();
    _cam = widget.video;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _sec++);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_sec ~/ 60).toString().padLeft(2, '0');
    final s = (_sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _playGame(String game) {
    final prompts = _games[game]!;
    final rand = Random();
    var current = prompts[rand.nextInt(prompts.length)];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(game),
          content: Text(current, style: const TextStyle(height: 1.5)),
          actions: [
            TextButton(
              onPressed: () =>
                  setD(() => current = prompts[rand.nextInt(prompts.length)]),
              child: const Text('Another'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _room() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Virtual date room · icebreaker games',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ..._games.keys.map(
              (g) => ListTile(
                leading: const Icon(Icons.sports_esports, color: C.saffron),
                title: Text(g),
                onTap: () {
                  Navigator.pop(ctx);
                  _playGame(g);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, bool active, VoidCallback onTap) => RoundBtn(
        icon: icon,
        color: active ? C.saffron : Colors.white,
        size: 56,
        onTap: onTap,
      );

  // Calls always use the dark theme so controls stay visible on black.
  @override
  Widget build(BuildContext context) => Theme(
        data: buildTheme(Brightness.dark),
        child: Builder(builder: _body),
      );

  Widget _body(BuildContext context) {
    final p = widget.p;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [fade(p.c1, .55), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              PersonAvatar(p, size: 120, showOnline: false),
              const SizedBox(height: 18),
              Text(p.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                _connected ? _clock : 'Calling…',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                widget.video
                    ? (_cam ? 'Video call · camera preview simulated' : 'Video call · camera off')
                    : 'Audio call',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _btn(_mute ? Icons.mic_off : Icons.mic, _mute,
                        () => setState(() => _mute = !_mute)),
                    _btn(_cam ? Icons.videocam : Icons.videocam_off, !_cam,
                        () => setState(() => _cam = !_cam)),
                    _btn(_speaker ? Icons.volume_up : Icons.volume_off, !_speaker,
                        () => setState(() => _speaker = !_speaker)),
                    _btn(Icons.sports_esports, false, _room),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
