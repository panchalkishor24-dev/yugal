import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../data.dart';
import '../ai.dart';
import '../i18n.dart';
import '../widgets.dart';
import 'premium.dart';
import 'safety.dart';
import 'admin.dart';
import 'onboarding.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  void _bio() {
    final f = AiService.writeBio(
      name: Me.name,
      job: Me.job,
      interests: Me.interests,
      goals: Me.goals,
    );
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<String>(
        future: f,
        builder: (c, s) => AlertDialog(
          title: const Text('AI profile writer'),
          content: s.hasData
              ? SelectableText(s.data!, style: const TextStyle(height: 1.5))
              : const Row(
                  children: [
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 14),
                    Text('Writing your bio…'),
                  ],
                ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            if (s.hasData)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: s.data!));
                  Navigator.pop(ctx);
                  snack(context, 'Bio copied');
                },
                child: const Text('Copy'),
              ),
          ],
        ),
      ),
    );
  }

  void _photo() {
    final r = AiService.analyzePhoto();
    final tips = r['tips'] as List<String>;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Photo quality: ${r['score']}/100'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $t'),
              ),
            ),
            const SizedBox(height: 4),
            Text('Demo result — production analyses your real photos on the server.',
                style: TextStyle(color: ctx.sub, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _coach() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CoachSheet(),
    );
  }

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap,
      {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fade(C.saffron, .15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: C.saffron, size: 20),
        ),
        title: Text(title,
            style: TextStyle(color: context.ink, fontWeight: FontWeight.w600)),
        subtitle: Text(sub, style: TextStyle(color: context.sub, fontSize: 12)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: context.sub),
      ),
    );
  }

  Widget _stat(String n, String l) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.line),
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (r) => C.grad.createShader(r),
                child: Text(n,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ),
              Text(l, style: TextStyle(color: context.sub, fontSize: 11)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [fade(C.saffron, .2), fade(C.rose, .2)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  InitialAvatar(
                    letter: Me.name.isEmpty ? 'Y' : Me.name[0],
                    c1: C.saffron,
                    c2: C.rose,
                    size: 72,
                    ring: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${Me.name}, ${Me.age}',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: context.ink,
                            )),
                        if (Me.job.isNotEmpty)
                          Text(Me.job, style: TextStyle(color: context.sub)),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: Me.planN,
                          builder: (context, plan, _) => Wrap(
                            spacing: 6,
                            children: [
                              if (Me.authScore >= 70)
                                const Pill('Verified', color: C.gold, icon: Icons.verified),
                              Pill(plan, color: C.saffron),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: Me.authScore / 100,
                            strokeWidth: 5,
                            color: C.gold,
                            backgroundColor: context.line,
                          ),
                        ),
                        Text('${Me.authScore}',
                            style: TextStyle(
                                color: context.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [_stat('127', 'Views'), _stat('43', 'Likes'), _stat('12', 'Matches')]),
            const SectionLabel('AI tools'),
            _tile(Icons.auto_awesome, 'AI profile writer',
                'Generate a bio from your interests', _bio),
            _tile(Icons.photo_camera_outlined, 'Photo quality analyzer',
                'Get tips to improve your photos', _photo),
            _tile(Icons.psychology_alt_outlined, 'AI dating coach',
                'Openers, date ideas and advice', _coach),
            const SectionLabel('Account'),
            _tile(Icons.workspace_premium_outlined, tr('premium'),
                'Plans, boosts and verification badge', () => _push(const PremiumScreen())),
            _tile(Icons.shield_outlined, tr('safety'),
                'SOS, trusted contacts, protection', () => _push(const SafetyScreen())),
            _tile(Icons.admin_panel_settings_outlined, 'Admin panel',
                'Demo dashboard for moderators', () => _push(const AdminScreen())),
            const SectionLabel('Settings'),
            _tile(
              Icons.dark_mode_outlined,
              'Dark mode',
              'Switch between light and dark',
              () {},
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeMode,
                builder: (_, m, __) => Switch(
                  value: m != ThemeMode.light,
                  onChanged: (v) =>
                      themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ),
            _tile(Icons.translate, tr('language'), langNames[appLang.value]!,
                () => showModalBottomSheet(
                    context: context, builder: (_) => const LanguageSheet())),
            _tile(
              Icons.visibility_off_outlined,
              'Incognito mode',
              'Browse without being seen (Premium)',
              () {},
              trailing: Switch(
                value: Me.incognito,
                onChanged: (v) {
                  if (!Me.premium) {
                    showUpsell(context, 'Incognito mode is a Premium feature');
                    return;
                  }
                  setState(() => Me.incognito = v);
                },
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (r) => false,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: C.rose,
                side: const BorderSide(color: C.rose),
              ),
              child: const Text('Sign out'),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => snack(context,
                    'Account deletion is available here in the production app.'),
                child: Text('Delete account', style: TextStyle(color: context.sub)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachSheet extends StatefulWidget {
  const _CoachSheet();

  @override
  State<_CoachSheet> createState() => _CoachSheetState();
}

class _CoachSheetState extends State<_CoachSheet> {
  final _c = TextEditingController();
  final List<MapEntry<bool, String>> _log = [
    MapEntry(false, 'Namaste! I am your Yugal dating coach. Ask me anything.'),
  ];

  static const _quick = [
    'How do I start a conversation?',
    'First date ideas?',
    'How to talk to family about us?',
  ];

  void _ask(String q) {
    if (q.trim().isEmpty) return;
    setState(() {
      _log.add(MapEntry(true, q.trim()));
      _log.add(MapEntry(false, AiService.coachReply(q)));
      _c.clear();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('AI dating coach',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _log
                    .map(
                      (e) => Align(
                        alignment:
                            e.key ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * .78),
                          decoration: BoxDecoration(
                            gradient: e.key ? C.grad : null,
                            color: e.key ? null : context.surf,
                            border: e.key ? null : Border.all(color: context.line),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(e.value,
                              style: TextStyle(
                                  color: e.key ? Colors.white : context.ink,
                                  height: 1.4)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _quick
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(q, style: const TextStyle(fontSize: 12)),
                            onPressed: () => _ask(q),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _c,
                      onSubmitted: _ask,
                      decoration: const InputDecoration(
                        hintText: 'Ask your coach…',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RoundBtn(
                    icon: Icons.send,
                    color: Colors.white,
                    size: 46,
                    filled: true,
                    onTap: () => _ask(_c.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
