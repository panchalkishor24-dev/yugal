import 'package:flutter/material.dart';
import '../theme.dart';
import '../i18n.dart';
import '../widgets.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _pages = [
    [
      '💫',
      'Find your\nYugal',
      'AI-powered matching crafted for Indian hearts — where tradition meets modern love.'
    ],
    [
      '🛡️',
      'Verified\n& safe',
      'Selfie and ID verification, authenticity scores and 24×7 AI moderation keep you safe.'
    ],
    [
      '✨',
      'Your journey,\nyour choice',
      'Marriage, long-term, friendship or casual — choose what you are looking for.'
    ],
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: C.grad,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🪷'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Yugal',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: context.ink,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => const LanguageSheet(),
                      ),
                      icon: const Icon(Icons.translate, size: 18),
                      label: Text(langNames[appLang.value]!),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final pg = _pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pg[0], style: const TextStyle(fontSize: 88)),
                          const SizedBox(height: 28),
                          Text(
                            i == 0 ? tr('tagline') : pg[1],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 34,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: context.ink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pg[2],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.sub,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      width: i == _page ? 28 : 8,
                      decoration: BoxDecoration(
                        color: i == _page ? C.saffron : context.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: _page < _pages.length - 1 ? tr('cont') : tr('start'),
                  onTap: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
