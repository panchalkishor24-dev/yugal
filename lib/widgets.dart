import 'package:flutter/material.dart';
import 'theme.dart';
import 'i18n.dart';
import 'data.dart';

/// Rebuilds its child whenever the app language changes.
class LangBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  const LangBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: appLang,
        builder: (ctx, _, __) => builder(ctx),
      );
}

String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

String rupees(int v) =>
    '₹${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: C.grad,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: fade(C.saffron, .35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InitialAvatar extends StatelessWidget {
  final String letter;
  final Color c1;
  final Color c2;
  final double size;
  final bool ring;
  final bool online;
  const InitialAvatar({
    super.key,
    required this.letter,
    required this.c1,
    required this.c2,
    this.size = 48,
    this.ring = false,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: ring ? Border.all(color: C.saffron, width: 2) : null,
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * .42,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * .24,
                height: size * .24,
                decoration: BoxDecoration(
                  color: C.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.bg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  final Person p;
  final double size;
  final bool ring;
  final bool showOnline;
  const PersonAvatar(
    this.p, {
    super.key,
    this.size = 48,
    this.ring = false,
    this.showOnline = true,
  });

  @override
  Widget build(BuildContext context) => InitialAvatar(
        letter: p.name[0],
        c1: p.c1,
        c2: p.c2,
        size: size,
        ring: ring,
        online: showOnline && p.online,
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color = C.saffron, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fade(color, .2),
        border: Border.all(color: fade(color, .5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: context.sub,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class CompatBar extends StatelessWidget {
  final int value;
  final Color? color;
  const CompatBar(this.value, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (value >= 90 ? C.rose : C.gold);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: context.line,
              color: c,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value%',
          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ],
    );
  }
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool filled;
  const RoundBtn({
    super.key,
    required this.icon,
    required this.color,
    this.size = 56,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? .35 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: filled ? C.grad : null,
            color: filled ? null : context.surf,
            border: filled
                ? null
                : Border.all(color: fade(color, .6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: fade(filled ? C.saffron : Colors.black, .25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: filled ? Colors.white : color, size: size * .45),
        ),
      ),
    );
  }
}

/// Multi / single select chips. Pass the current selection as a set.
class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  const ChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final on = selected.contains(o);
        return GestureDetector(
          onTap: () => onTap(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: on ? fade(C.saffron, .18) : context.surf,
              border: Border.all(color: on ? C.saffron : context.line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              o,
              style: TextStyle(
                color: on ? C.saffron : context.sub,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            ...langNames.entries.map(
              (e) => ListTile(
                title: Text(e.value),
                trailing: appLang.value == e.key
                    ? const Icon(Icons.check_circle, color: C.saffron)
                    : null,
                onTap: () {
                  appLang.value = e.key;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}
