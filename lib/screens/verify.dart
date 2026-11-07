import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets.dart';
import 'setup.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _selfie = false;
  bool _govId = false;
  bool _linkedin = false;

  int get _score =>
      40 + (_selfie ? 30 : 0) + (_govId ? 20 : 0) + (_linkedin ? 10 : 0);

  Future<void> _run(String what, VoidCallback done) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 18),
            Expanded(child: Text(what)),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.pop(context);
    setState(done);
  }

  Widget _step({
    required IconData icon,
    required String title,
    required String sub,
    required bool done,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: done ? C.green : context.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fade(done ? C.green : C.saffron, .15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(done ? Icons.check : icon, color: done ? C.green : C.saffron),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          style: TextStyle(
                              color: context.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                    if (optional) ...[
                      const SizedBox(width: 8),
                      const Pill('Optional', color: C.gold),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(sub,
                    style: TextStyle(color: context.sub, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!done)
            TextButton(onPressed: onTap, child: const Text('Start'))
          else
            const Text('Done',
                style: TextStyle(color: C.green, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _continue() {
    Me.authScore = _score;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selfie && _govId;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Verified profiles get up to 3× more matches and keep everyone safe.',
              style: TextStyle(color: context.sub, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [fade(C.saffron, .18), fade(C.rose, .18)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: _score / 100,
                            strokeWidth: 6,
                            color: C.gold,
                            backgroundColor: context.line,
                          ),
                        ),
                        Text('$_score',
                            style: TextStyle(
                                color: context.ink, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Authenticity score',
                            style: TextStyle(
                                color: context.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Shown as a trust badge on your profile',
                            style: TextStyle(color: context.sub, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _step(
              icon: Icons.face_retouching_natural,
              title: 'Selfie liveness check',
              sub: 'A quick selfie is matched with your photos to stop catfishing.',
              done: _selfie,
              onTap: () => _run('Checking selfie…', () => _selfie = true),
            ),
            _step(
              icon: Icons.badge_outlined,
              title: 'Government ID',
              sub: 'Aadhaar, PAN, passport or driving licence. Stored encrypted, never shown.',
              done: _govId,
              onTap: () => _run('Verifying ID…', () => _govId = true),
            ),
            _step(
              icon: Icons.work_outline,
              title: 'LinkedIn',
              sub: 'Confirm your job and education for a professional badge.',
              done: _linkedin,
              optional: true,
              onTap: () => _run('Linking LinkedIn…', () => _linkedin = true),
            ),
            const SizedBox(height: 8),
            Text(
              'Demo build: capture and verification are simulated. Production uses a liveness SDK '
              'and DigiLocker / e-KYC for ID checks.',
              style: TextStyle(color: context.sub, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Continue',
              onTap: canContinue ? _continue : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _continue,
                child: const Text('Skip for now (limited visibility)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
