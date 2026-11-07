import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets.dart';

/// Report / block sheet, reused from chat and profile detail.
void showReportSheet(BuildContext context, Person p) {
  final reasons = [
    'Fake profile / catfishing',
    'Harassment or abuse',
    'Inappropriate photos',
    'Asking for money (scam)',
    'Underage user',
    'Other',
  ];
  final selected = <String>{};
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surf,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report ${p.name.split(' ').first}',
                  style: TextStyle(
                      color: ctx.ink, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Reports are anonymous and reviewed by our safety team.',
                  style: TextStyle(color: ctx.sub, fontSize: 12)),
              const SizedBox(height: 16),
              ChipGroup(
                options: reasons,
                selected: selected,
                onTap: (v) => setS(() {
                  selected
                    ..clear()
                    ..add(v);
                }),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              snack(context, 'Report submitted. Thank you.');
                            },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      child: const Text('Report'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GradientButton(
                      label: 'Report & block',
                      height: 50,
                      onTap: selected.isEmpty
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              snack(context, '${p.name.split(' ').first} blocked.');
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  void _sos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send SOS alert?'),
        content: const Text(
          'This will message your trusted contacts with your live location. '
          'If you are in danger, also call 112 (national emergency number).',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              snack(context,
                  'SOS sent to ${Me.contacts.length} contact(s) (demo — no real message sent).');
            },
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  void _addContact() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add trusted contact'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: 'Name — phone number'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) {
                setState(() => Me.contacts.add(c.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _switch(String title, String sub, bool v, void Function(bool)? on) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: SwitchListTile(
        value: v,
        onChanged: on,
        title: Text(title,
            style: TextStyle(color: context.ink, fontWeight: FontWeight.w600)),
        subtitle: Text(sub, style: TextStyle(color: context.sub, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: fade(Colors.red, .12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: fade(Colors.red, .4)),
            ),
            child: Column(
              children: [
                const Icon(Icons.sos, color: Colors.red, size: 44),
                const SizedBox(height: 8),
                Text('Emergency SOS',
                    style: TextStyle(
                        color: context.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Alert trusted contacts with your live location in one tap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.sub),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _sos,
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('Send SOS'),
                ),
              ],
            ),
          ),
          const SectionLabel('Trusted contacts'),
          ...Me.contacts.map(
            (c) => ListTile(
              leading: const Icon(Icons.person_pin_circle_outlined, color: C.saffron),
              title: Text(c),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => Me.contacts.remove(c)),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.add),
            label: const Text('Add contact'),
          ),
          const SectionLabel('Protection'),
          _switch('Screenshot alerts', 'Get notified when someone captures your chat',
              Me.screenshotAlerts, (v) => setState(() => Me.screenshotAlerts = v)),
          _switch('AI moderation', 'Always on · blocks harassment & explicit content',
              true, null),
          _switch('Anti-catfishing checks', 'Always on · compares selfies with photos',
              true, null),
          const SectionLabel('Dating safely'),
          ...const [
            'Meet in a public place for the first few dates.',
            'Tell a friend or family member where you are going.',
            'Never share OTPs, bank details or send money to a match.',
            'Video-call before meeting in person.',
            'Report anyone who makes you uncomfortable — we act fast.',
          ].map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: C.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t,
                        style: TextStyle(color: context.sub, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
