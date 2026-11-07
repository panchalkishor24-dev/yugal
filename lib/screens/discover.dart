import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../ai.dart';
import '../widgets.dart';
import 'chat.dart';
import 'premium.dart';
import 'safety.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const _filters = ['For You', 'Nearby', 'Trending', 'New'];
  int _filter = 0;
  List<Person> _deck = [];
  int _i = 0;
  final List<int> _history = [];
  Offset _drag = Offset.zero;
  bool _dragging = false;
  int _exit = 0; // 1 like, -1 pass, 2 super like
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _rebuildDeck();
  }

  void _rebuildDeck() {
    var l = List<Person>.from(people);
    switch (_filter) {
      case 1:
        l.sort((a, b) => a.km.compareTo(b.km));
        break;
      case 2:
        l = l.where((p) => p.trending).toList();
        break;
      case 3:
        l = l.where((p) => p.isNew).toList();
        break;
      default:
        l.sort((a, b) => b.compat.compareTo(a.compat));
    }
    _deck = l;
    _i = 0;
    _history.clear();
    _drag = Offset.zero;
    _exit = 0;
    _busy = false;
  }

  void _decide(int dir) {
    if (_busy || _i >= _deck.length) return;
    if (dir == 1 && !Me.premium && Me.likesLeft <= 0) {
      setState(() => _drag = Offset.zero);
      showUpsell(context, 'You have used all free likes for today');
      return;
    }
    if (dir == 2 && Me.superLikes <= 0) {
      setState(() => _drag = Offset.zero);
      showUpsell(context, 'You are out of Super Likes');
      return;
    }
    final p = _deck[_i];
    setState(() {
      _busy = true;
      _dragging = false;
      _exit = dir;
      if (dir == 1 && !Me.premium) Me.likesLeft--;
      if (dir == 2) Me.superLikes--;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _history.add(_i);
        _i++;
        _drag = Offset.zero;
        _exit = 0;
        _busy = false;
      });
      // Demo rule: some likes become instant matches.
      if (dir > 0 && (p.id.isOdd || dir == 2)) _showMatch(p);
    });
  }

  void _rewind() {
    if (_history.isEmpty || _busy) return;
    setState(() => _i = _history.removeLast());
  }

  void _boost() {
    if (!Me.premium) {
      showUpsell(context, 'Boost your profile to be seen first');
      return;
    }
    snack(context, 'Profile boosted for 30 minutes 🚀');
  }

  void _openDetail(Person p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailSheet(
        p: p,
        onLike: () => _decide(1),
        onPass: () => _decide(-1),
      ),
    );
  }

  void _showMatch(Person p) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (r) => C.grad.createShader(r),
                child: const Text(
                  "It's a Yugal! 💞",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('You and ${p.name.split(' ').first} liked each other',
                  style: TextStyle(color: ctx.sub)),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InitialAvatar(
                    letter: Me.name.isEmpty ? 'Y' : Me.name[0],
                    c1: C.saffron,
                    c2: C.rose,
                    size: 76,
                    ring: true,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.favorite, color: C.rose),
                  const SizedBox(width: 16),
                  PersonAvatar(p, size: 76, ring: true, showOnline: false),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Say hi 👋',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen(p: p)),
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Keep swiping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topCard(Person p, Size size) {
    final w = size.width;
    final dx = _exit == 0 ? _drag.dx : (_exit > 0 ? w * 1.4 : -w * 1.4);
    final dy = _exit == 2 ? -size.height : (_exit == 0 ? _drag.dy : 0.0);
    final angle =
        (_exit == 0 ? _drag.dx : (_exit > 0 ? 300.0 : -300.0)) / 1200;
    final like = _exit == 0 ? (_drag.dx / 110).clamp(0.0, 1.0).toDouble() : 0.0;
    final nope = _exit == 0 ? (-_drag.dx / 110).clamp(0.0, 1.0).toDouble() : 0.0;
    return GestureDetector(
      key: ValueKey(p.id),
      onTap: () => _openDetail(p),
      onPanStart: (_) => setState(() => _dragging = true),
      onPanUpdate: (d) => setState(() => _drag += d.delta),
      onPanEnd: (_) {
        setState(() => _dragging = false);
        if (_drag.dx > 110) {
          _decide(1);
        } else if (_drag.dx < -110) {
          _decide(-1);
        } else if (_drag.dy < -140) {
          _decide(2);
        } else {
          setState(() => _drag = Offset.zero);
        }
      },
      child: AnimatedContainer(
        duration: _dragging ? Duration.zero : const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(dx, dy, 0)..rotateZ(angle),
        transformAlignment: Alignment.bottomCenter,
        child: _CardFace(p: p, like: like, nope: nope),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (r) => C.grad.createShader(r),
            child: const Text(
              'Yugal',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<String>(
            valueListenable: Me.planN,
            builder: (context, plan, _) => plan == 'Free'
                ? Pill('${Me.likesLeft} likes left', color: C.gold, icon: Icons.favorite)
                : Pill(plan, color: C.saffron, icon: Icons.workspace_premium),
          ),
          IconButton(
            tooltip: 'Report / safety',
            icon: Icon(Icons.shield_outlined, color: context.sub),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafetyScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final on = i == _filter;
          return GestureDetector(
            onTap: () => setState(() {
              _filter = i;
              _rebuildDeck();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: on ? C.grad : null,
                color: on ? null : context.surf,
                border: on ? null : Border.all(color: context.line),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: on ? Colors.white : context.sub,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            "You're all caught up",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fresh curated matches arrive every day.',
            style: TextStyle(color: context.sub),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: GradientButton(
              label: 'Reload',
              onTap: () => setState(_rebuildDeck),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundBtn(
            icon: Icons.replay,
            color: C.gold,
            size: 46,
            onTap: _history.isEmpty ? null : _rewind,
          ),
          RoundBtn(icon: Icons.close, color: C.rose, size: 58, onTap: () => _decide(-1)),
          RoundBtn(
            icon: Icons.favorite,
            color: Colors.white,
            size: 68,
            filled: true,
            onTap: () => _decide(1),
          ),
          RoundBtn(
            icon: Icons.star,
            color: Colors.lightBlueAccent,
            size: 58,
            onTap: () => _decide(2),
          ),
          RoundBtn(icon: Icons.bolt, color: Colors.purpleAccent, size: 46, onTap: _boost),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final done = _i >= _deck.length;
    return SafeArea(
      child: Column(
        children: [
          _header(),
          _filterRow(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: done
                  ? _empty()
                  : Stack(
                      children: [
                        if (_i + 1 < _deck.length)
                          Positioned.fill(
                            child: Transform.scale(
                              scale: .94,
                              child: Opacity(
                                opacity: .75,
                                child: _CardFace(p: _deck[_i + 1]),
                              ),
                            ),
                          ),
                        Positioned.fill(child: _topCard(_deck[_i], size)),
                      ],
                    ),
            ),
          ),
          if (!done) _actions(),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final Person p;
  final double like;
  final double nope;
  const _CardFace({required this.p, this.like = 0, this.nope = 0});

  Widget _stamp(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          t,
          style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 28),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
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
          Align(
            alignment: const Alignment(0, -.35),
            child: Text(p.emoji, style: const TextStyle(fontSize: 120)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent, Colors.black87],
                stops: [0, .45, 1],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                if (p.verified)
                  const Pill('Verified', color: C.gold, icon: Icons.verified),
                const Spacer(),
                Pill('${p.compat}% match',
                    color: p.compat >= 90 ? C.rose : C.gold),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${p.name}, ${p.age}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (p.online) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.circle, color: C.green, size: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.job} · ${p.city} · ${p.km} km away',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: p.interests
                      .take(3)
                      .map(
                        (i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(i,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap for full profile & AI compatibility report',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          if (like > 0)
            Positioned(
              top: 70,
              left: 24,
              child: Opacity(opacity: like, child: _stamp('LIKE', C.green)),
            ),
          if (nope > 0)
            Positioned(
              top: 70,
              right: 24,
              child: Opacity(opacity: nope, child: _stamp('NOPE', C.rose)),
            ),
        ],
      ),
    );
  }
}

class DetailSheet extends StatelessWidget {
  final Person p;
  final VoidCallback onLike;
  final VoidCallback onPass;
  const DetailSheet({
    super.key,
    required this.p,
    required this.onLike,
    required this.onPass,
  });

  Widget _tile(BuildContext c, String k, String v, double w) {
    return SizedBox(
      width: w,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: TextStyle(color: c.sub, fontSize: 11)),
            const SizedBox(height: 2),
            Text(v,
                style: TextStyle(
                    color: c.ink, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bd = AiService.compatBreakdown(p);
    final tileW = (MediaQuery.of(context).size.width - 50) / 2;
    return DraggableScrollableSheet(
      initialChildSize: .88,
      minChildSize: .5,
      maxChildSize: .95,
      expand: false,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                PersonAvatar(p, size: 72, ring: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.name}, ${p.age}',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ctx.ink,
                          )),
                      Text('${p.job} · ${p.city}',
                          style: TextStyle(color: ctx.sub)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (p.verified)
                            const Pill('Verified', color: C.gold, icon: Icons.verified),
                          Pill('Authenticity ${p.verified ? 96 : 60}', color: C.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ctx.surf,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ctx.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: C.saffron, size: 18),
                      const SizedBox(width: 8),
                      Text('AI compatibility report',
                          style: TextStyle(
                              color: ctx.ink, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${p.compat}%',
                          style: const TextStyle(
                              color: C.saffron,
                              fontWeight: FontWeight.w900,
                              fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...bd.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key,
                              style: TextStyle(color: ctx.sub, fontSize: 12)),
                          const SizedBox(height: 4),
                          CompatBar(e.value),
                        ],
                      ),
                    ),
                  ),
                  Text(AiService.compatSummary(p),
                      style: TextStyle(color: ctx.sub, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SectionLabel('About'),
            Text(p.bio, style: TextStyle(color: ctx.ink, height: 1.6)),
            const SectionLabel('Details'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _tile(ctx, 'Education', p.education, tileW),
                _tile(ctx, 'Religion', p.religion, tileW),
                _tile(ctx, 'Community', p.community, tileW),
                _tile(ctx, 'Diet', p.diet, tileW),
                _tile(ctx, 'Height', p.height, tileW),
                _tile(ctx, 'Distance', '${p.km} km', tileW),
              ],
            ),
            const SectionLabel('Interests'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.interests
                  .map((i) => Pill(i, color: C.saffron))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onPass();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      foregroundColor: C.rose,
                      side: const BorderSide(color: C.rose),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Pass'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Like ${p.name.split(' ').first}',
                    icon: Icons.favorite,
                    onTap: () {
                      Navigator.pop(ctx);
                      onLike();
                    },
                  ),
                ),
              ],
            ),
            Center(
              child: TextButton(
                onPressed: () => showReportSheet(ctx, p),
                child: const Text('Report or block'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
