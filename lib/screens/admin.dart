import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

/// Demo moderator dashboard with sample data. The production admin panel is a
/// separate web app (see README) behind staff SSO + role-based access.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<List<String>> _queue = [
    ['Rahul Singh', 'Delhi', 'Selfie + Aadhaar'],
    ['Sneha Patil', 'Pune', 'Selfie + PAN'],
    ['Karthik R', 'Chennai', 'Selfie + Passport'],
  ];

  final List<List<String>> _fraud = [
    ['Same photo used on 3 accounts', 'High'],
    ['Repeated "send money" messages', 'High'],
    ['Rapid likes from one device (bot pattern)', 'Medium'],
  ];

  static const _dau = [60, 66, 62, 74, 70, 82, 78, 88, 84, 90, 86, 95, 92, 100];

  Widget _kpi(String label, String value, String delta, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: context.sub, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            Text(delta, style: const TextStyle(color: C.green, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: context.ink, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text('Sample data for demonstration',
                style: TextStyle(color: context.sub, fontSize: 12)),
          ),
          Row(children: [
            _kpi('Total users', '2.4M', '+12% wk', C.saffron),
            _kpi('Active today', '183K', '+8% wk', C.green),
          ]),
          Row(children: [
            _kpi('New signups', '4,821', '+23% wk', C.gold),
            _kpi('Revenue MTD', '₹4.2 Cr', '+18% wk', C.rose),
          ]),
          _card(
            'Daily active users (14 days)',
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_dau.length, (i) {
                  final last = i == _dau.length - 1;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 90 * _dau[i] / 100,
                      decoration: BoxDecoration(
                        gradient: last ? C.grad : null,
                        color: last ? null : fade(C.saffron, .35),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          _card(
            'Revenue by source',
            Column(
              children: [
                _rev('Premium subscriptions', 62),
                _rev('VIP / concierge', 21),
                _rev('Boosts', 11),
                _rev('Super Likes', 6),
              ],
            ),
          ),
          _card(
            'Verification queue',
            _queue.isEmpty
                ? Text('All caught up 🎉', style: TextStyle(color: context.sub))
                : Column(
                    children: _queue
                        .map(
                          (u) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(u[0],
                                style: TextStyle(
                                    color: context.ink,
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text('${u[1]} · ${u[2]}',
                                style: TextStyle(
                                    color: context.sub, fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close, color: C.rose),
                                  onPressed: () => setState(() => _queue.remove(u)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check, color: C.green),
                                  onPressed: () => setState(() => _queue.remove(u)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          _card(
            'Fraud & moderation alerts',
            Column(
              children: _fraud
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: f[1] == 'High' ? C.rose : C.gold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(f[0],
                                style: TextStyle(color: context.ink, fontSize: 13)),
                          ),
                          Pill(f[1], color: f[1] == 'High' ? C.rose : C.gold),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rev(String label, int pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.sub, fontSize: 12)),
          const SizedBox(height: 4),
          CompatBar(pct, color: C.saffron),
        ],
      ),
    );
  }
}
