import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets.dart';
import 'premium.dart';
import 'chat.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admirers = people.sublist(2, 8);
    return SafeArea(
      child: ValueListenableBuilder<String>(
        valueListenable: Me.planN,
        builder: (context, plan, _) {
          final unlocked = plan != 'Free';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  'Liked you',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: context.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  '${admirers.length} people are interested in you',
                  style: TextStyle(color: context.sub),
                ),
              ),
              if (!unlocked)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: GradientButton(
                    label: 'Upgrade to see who liked you',
                    icon: Icons.lock_open,
                    height: 48,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .78,
                  ),
                  itemCount: admirers.length,
                  itemBuilder: (_, i) {
                    final p = admirers[i];
                    final face = ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [p.c1, p.c2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(p.emoji,
                                style: const TextStyle(fontSize: 64)),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 10,
                            child: Text(
                              '${p.name.split(' ').first}, ${p.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return GestureDetector(
                      onTap: () {
                        if (!unlocked) {
                          showUpsell(context, 'See everyone who liked you');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChatScreen(p: p)),
                          );
                        }
                      },
                      child: unlocked
                          ? face
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                    child: face,
                                  ),
                                ),
                                const Center(
                                  child: Icon(Icons.lock, color: Colors.white, size: 30),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
