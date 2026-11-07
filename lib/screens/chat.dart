import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../ai.dart';
import '../i18n.dart';
import '../widgets.dart';
import 'call.dart';
import 'safety.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const _previews = [
    ['That trek sounds amazing! 🏔️', '2m', '2'],
    ['Haha yes, the biryani debate is real 😂', '1h', '0'],
    ['Which Murakami did you start with?', '3h', '1'],
    ['That dog picture is everything 🐶', '1d', '0'],
  ];

  void _open(BuildContext c, Person p) => Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => ChatScreen(p: p)),
      );

  @override
  Widget build(BuildContext context) {
    final fresh = people.sublist(4, 8);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              'Messages',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: context.ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('NEW MATCHES',
                style: TextStyle(
                    color: context.sub,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: fresh.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _open(context, fresh[i]),
                child: Column(
                  children: [
                    PersonAvatar(fresh[i], size: 64, ring: true),
                    const SizedBox(height: 6),
                    Text(fresh[i].name.split(' ').first,
                        style: TextStyle(color: context.sub, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('CONVERSATIONS',
                style: TextStyle(
                    color: context.sub,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < _previews.length; i++)
            ListTile(
              onTap: () => _open(context, people[i]),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: PersonAvatar(people[i], size: 52),
              title: Text(
                people[i].name,
                style: TextStyle(
                  color: context.ink,
                  fontWeight: _previews[i][2] != '0'
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _previews[i][0],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.sub),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_previews[i][1],
                      style: TextStyle(color: context.sub, fontSize: 11)),
                  if (_previews[i][2] != '0') ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: C.saffron, shape: BoxShape.circle),
                      child: Text(_previews[i][2],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Msg {
  final String text;
  final bool mine;
  final String kind; // text | voice | image
  final DateTime at = DateTime.now();
  int status; // 0 sent, 1 delivered, 2 read
  Msg(this.text, this.mine, {this.kind = 'text', this.status = 0});
}

class ChatScreen extends StatefulWidget {
  final Person p;
  const ChatScreen({super.key, required this.p});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _c = TextEditingController();
  final _scroll = ScrollController();
  final _rand = Random();
  final List<Msg> _msgs = [];
  bool _typing = false;
  String? _translateTo;

  static const _replies = [
    'Haha, that made my day 😄',
    'Tell me more!',
    'That sounds lovely. What are you up to this weekend?',
    'Honestly, same here. We should plan something.',
    'Ooh, I like that. Ever tried it with friends?',
  ];

  @override
  void initState() {
    super.initState();
    _msgs.add(Msg('Hi! Looks like we both love ${widget.p.interests.first} 😊', false,
        status: 2));
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text, {String kind = 'text'}) {
    if (kind == 'text' && text.trim().isEmpty) return;
    final m = Msg(text.trim(), true, kind: kind);
    setState(() {
      _msgs.add(m);
      _c.clear();
    });
    _toEnd();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => m.status = 1);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _typing = true);
      _toEnd();
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        m.status = 2;
        _typing = false;
        _msgs.add(Msg(_replies[_rand.nextInt(_replies.length)], false, status: 2));
      });
      _toEnd();
    });
  }

  void _call(bool video) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CallScreen(p: widget.p, video: video)),
      );

  void _pickTranslate() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Translate incoming messages to…',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              ListTile(
                title: const Text('Off'),
                onTap: () {
                  setState(() => _translateTo = null);
                  Navigator.pop(ctx);
                },
              ),
              ...langNames.entries.map(
                (e) => ListTile(
                  title: Text(e.value),
                  trailing: _translateTo == e.key
                      ? const Icon(Icons.check_circle, color: C.saffron)
                      : null,
                  onTap: () {
                    setState(() => _translateTo = e.key);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final hasText = _c.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            PersonAvatar(p, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name.split(' ').first,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    _typing ? 'typing…' : (p.online ? 'Online' : 'Offline'),
                    style: TextStyle(
                        fontSize: 11,
                        color: _typing || p.online ? C.green : context.sub),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => _call(false)),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () => _call(true)),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'translate') _pickTranslate();
              if (v == 'report') showReportSheet(context, p);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'translate', child: Text('Translate chat')),
              PopupMenuItem(value: 'report', child: Text('Report / block')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: fade(C.saffron, .08),
            child: Text(
              '🔒 Protected chat · screenshot alerts ${Me.screenshotAlerts ? 'on' : 'off'}'
              '${_translateTo != null ? ' · translating → ${langNames[_translateTo]}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.sub, fontSize: 11),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.surf,
                        border: Border.all(color: context.line),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text('typing…',
                          style: TextStyle(
                              color: context.sub, fontStyle: FontStyle.italic)),
                    ),
                  );
                }
                return _Bubble(m: _msgs[i], translateTo: _translateTo);
              },
            ),
          ),
          if (_msgs.length < 4)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: AiService.icebreakers(p)
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.auto_awesome, size: 14, color: C.saffron),
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          onPressed: () => _c.text = s,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: () => _send('Photo', kind: 'image'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _c,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.line),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  hasText
                      ? RoundBtn(
                          icon: Icons.send,
                          color: Colors.white,
                          size: 44,
                          filled: true,
                          onTap: () => _send(_c.text),
                        )
                      : RoundBtn(
                          icon: Icons.mic,
                          color: C.saffron,
                          size: 44,
                          onTap: () => _send('0:07', kind: 'voice'),
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

class _Bubble extends StatelessWidget {
  final Msg m;
  final String? translateTo;
  const _Bubble({required this.m, this.translateTo});

  Widget _content(BuildContext context, Color fg) {
    switch (m.kind) {
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: fg),
            const SizedBox(width: 4),
            ...List.generate(
              18,
              (i) => Container(
                width: 3,
                height: 6.0 + (i * 7 % 14),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: fade(fg, .7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(m.text, style: TextStyle(color: fg, fontSize: 12)),
          ],
        );
      case 'image':
        return Container(
          width: 180,
          height: 120,
          decoration: BoxDecoration(
            gradient: C.gradGold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.image, color: Colors.white, size: 40),
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.text, style: TextStyle(color: fg, fontSize: 15, height: 1.35)),
            if (translateTo != null && !m.mine) ...[
              const SizedBox(height: 6),
              Text(
                '🌐 ${AiService.translate(m.text, translateTo!)}',
                style: TextStyle(
                    color: fade(fg, .7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = m.mine ? Colors.white : context.ink;
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .76),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 6),
        decoration: BoxDecoration(
          gradient: m.mine ? C.grad : null,
          color: m.mine ? null : context.surf,
          border: m.mine ? null : Border.all(color: context.line),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(m.mine ? 18 : 4),
            bottomRight: Radius.circular(m.mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _content(context, fg),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(fmtTime(m.at),
                    style: TextStyle(color: fade(fg, .6), fontSize: 10)),
                if (m.mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    m.status == 0 ? Icons.done : Icons.done_all,
                    size: 14,
                    // Blue "read" ticks are a Premium feature.
                    color: m.status == 2 && Me.premium
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
