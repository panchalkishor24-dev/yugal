import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets.dart';

/// Bottom sheet shown when a free user hits a premium-only limit.
void showUpsell(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.surf,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ctx.ink, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Go Premium for unlimited likes, see who liked you, advanced filters and more.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ctx.sub, height: 1.5),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'See plans',
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _Plan {
  final String name;
  final int base;
  final Color color;
  final List<String> features;
  const _Plan(this.name, this.base, this.color, this.features);
}

const _plans = [
  _Plan('Free', 0, C.muted, [
    '20 likes per day',
    'Basic matching',
    'Limited chats',
    '1 Super Like',
  ]),
  _Plan('Premium', 999, C.saffron, [
    'Unlimited likes',
    'See who liked you',
    'Advanced filters',
    'Priority profile boost',
    'Read receipts',
    'Incognito mode',
  ]),
  _Plan('VIP', 2499, C.gold, [
    'Everything in Premium',
    'Dedicated relationship concierge',
    'Profile optimisation by experts',
    'Exclusive matchmaking suggestions',
    'Priority support',
  ]),
];

const _durLabels = ['1 month', '3 months', '6 months'];
const _durMonths = [1, 3, 6];
const _durFactor = [1.0, 0.85, 0.7];

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _dur = 0;

  int _price(_Plan p) =>
      (p.base * _durMonths[_dur] * _durFactor[_dur]).round();

  void _buyPlan(_Plan p) {
    showCheckout(
      context,
      title: '${p.name} · ${_durLabels[_dur]}',
      amount: _price(p),
      onPaid: () {
        Me.planN.value = p.name;
        if (mounted) setState(() {});
      },
    );
  }

  void _buyAddon(String title, int amount, VoidCallback apply) {
    showCheckout(context, title: title, amount: amount, onPaid: () {
      apply();
      if (mounted) setState(() {});
    });
  }

  Widget _addon(String emoji, String title, String sub, int amount, VoidCallback apply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 26)),
        title: Text(title,
            style: TextStyle(color: context.ink, fontWeight: FontWeight.w700)),
        subtitle: Text(sub, style: TextStyle(color: context.sub, fontSize: 12)),
        trailing: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: C.saffron),
          onPressed: () => _buyAddon(title, amount, apply),
          child: Text(rupees(amount)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yugal Plus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            children: List.generate(_durLabels.length, (i) {
              final on = i == _dur;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _dur = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: on ? C.grad : null,
                      color: on ? null : context.surf,
                      border: on ? null : Border.all(color: context.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(_durLabels[i],
                            style: TextStyle(
                                color: on ? Colors.white : context.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        if (i > 0)
                          Text('Save ${((1 - _durFactor[i]) * 100).round()}%',
                              style: TextStyle(
                                  color: on ? Colors.white70 : C.green,
                                  fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: Me.planN,
            builder: (context, current, _) => Column(
              children: _plans.map((pl) {
                final isCurrent = pl.name == current;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.surf,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isCurrent ? pl.color : context.line,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(pl.name,
                              style: TextStyle(
                                  color: context.ink,
                                  fontFamily: 'serif',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (isCurrent) Pill('Current', color: pl.color),
                          const Spacer(),
                          Text(
                            pl.base == 0 ? 'Free' : rupees(_price(pl)),
                            style: TextStyle(
                                color: pl.color,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...pl.features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: pl.color, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(f,
                                    style: TextStyle(
                                        color: context.sub, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (pl.base > 0 && !isCurrent) ...[
                        const SizedBox(height: 10),
                        GradientButton(
                          label: 'Choose ${pl.name}',
                          height: 48,
                          onTap: () => _buyPlan(pl),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SectionLabel('Boosts & extras'),
          _addon('⚡', 'Profile boost', 'Be seen first for 30 minutes', 99,
              () => snack(context, 'Boost activated ⚡')),
          _addon('★', '5 Super Likes', 'Stand out from the crowd', 199,
              () => Me.superLikes += 5),
          _addon('✅', 'Premium verification badge', 'Gold badge on your profile', 149,
              () => Me.authScore = 100),
          _addon('🌟', 'Featured placement', 'Top of Discover for 7 days', 499,
              () => snack(context, 'Featured for 7 days 🌟')),
        ],
      ),
    );
  }
}

Future<void> showCheckout(
  BuildContext context, {
  required String title,
  required int amount,
  required VoidCallback onPaid,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surf,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _Checkout(title: title, amount: amount, onPaid: onPaid),
  );
}

class _Checkout extends StatefulWidget {
  final String title;
  final int amount;
  final VoidCallback onPaid;
  const _Checkout({required this.title, required this.amount, required this.onPaid});

  @override
  State<_Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<_Checkout> {
  String _method = 'Google Pay';
  bool _paying = false;
  bool _done = false;

  static const _methods = [
    ['Google Pay', 'UPI'],
    ['PhonePe', 'UPI'],
    ['Paytm', 'Wallet / UPI'],
    ['Any UPI app', 'Enter UPI ID'],
    ['Credit / Debit card', 'Visa, Mastercard, RuPay'],
    ['Razorpay Checkout', 'All methods'],
  ];

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _paying = false;
      _done = true;
    });
    widget.onPaid();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: _done
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.check_circle, color: C.green, size: 64),
                  const SizedBox(height: 12),
                  Text('Payment successful',
                      style: TextStyle(
                          color: context.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: TextStyle(
                          color: context.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Pay ${rupees(widget.amount)} (incl. GST)',
                      style: TextStyle(color: context.sub)),
                  const SizedBox(height: 14),
                  ..._methods.map(
                    (m) => GestureDetector(
                      onTap: () => setState(() => _method = m[0]),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _method == m[0] ? C.saffron : context.line),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _method == m[0]
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _method == m[0] ? C.saffron : context.sub,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(m[0],
                                  style: TextStyle(
                                      color: context.ink,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text(m[1],
                                style: TextStyle(color: context.sub, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GradientButton(
                    label: _paying ? 'Processing…' : 'Pay ${rupees(widget.amount)}',
                    onTap: _paying ? null : _pay,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Demo checkout — no money is charged. Production uses Razorpay '
                    '(UPI, cards, wallets) with server-side order creation and webhook verification.',
                    style: TextStyle(color: context.sub, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
      ),
    );
  }
}
