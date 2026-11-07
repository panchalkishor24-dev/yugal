import 'data.dart';
import 'i18n.dart';

/// Demo AI layer. Everything here is templated so the app works offline.
///
/// PRODUCTION: replace these with calls to YOUR backend (e.g. POST /v1/ai/bio,
/// /v1/ai/coach, /v1/ai/compat). The backend holds the OpenAI key and applies
/// moderation + rate limits. Never ship an OpenAI key inside the app.
class AiService {
  static Future<String> writeBio({
    required String name,
    required String job,
    required Set<String> interests,
    required Set<String> goals,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final who = name.trim().isEmpty || name == 'You' ? 'Hi' : "Hi, I'm ${name.trim()}";
    final role = job.trim().isEmpty ? 'Someone who loves what I do' : job.trim();
    final ints = interests.isEmpty
        ? 'good conversations and chai'
        : interests.take(3).join(', ').toLowerCase();
    final goal = goals.isEmpty ? 'something real' : goals.first.toLowerCase();
    return "$who. $role by day, $ints enthusiast by night. "
        "I'm looking for $goal with someone kind, curious and family-minded. "
        "Ask me about my favourite weekend plan!";
  }

  static List<String> icebreakers(Person p) {
    final i = p.interests.isEmpty ? 'travel' : p.interests.first.toLowerCase();
    return [
      'Hey ${p.name.split(' ').first}! I saw you love $i — what got you into it?',
      "Quick one: chai or coffee? Choose wisely 😄",
      "What's your ideal Sunday in ${p.city}?",
    ];
  }

  static int _clamp(int v) => v < 40 ? 40 : (v > 99 ? 99 : v);

  static Map<String, int> compatBreakdown(Person p) => {
        'Values & family outlook': _clamp(p.compat + 3),
        'Lifestyle & diet': _clamp(p.compat - 4),
        'Shared interests': _clamp(p.compat - 1),
        'Relationship goals': _clamp(p.compat + 2),
      };

  static String compatSummary(Person p) {
    final shared = p.interests.take(2).join(' and ');
    return 'You two line up on values and relationship goals. '
        'Shared interest in $shared gives you an easy first conversation. '
        'Worth discussing early: lifestyle routines and plans around family.';
  }

  static Map<String, Object> analyzePhoto() => {
        'score': 82,
        'tips': <String>[
          'Face is clear and well lit — great.',
          'Add one full-length photo to build trust.',
          'Avoid group shots as your first picture.',
          'A genuine smile outdoors performs best.',
        ],
      };

  static String coachReply(String q) {
    final s = q.toLowerCase();
    if (s.contains('start') || s.contains('message') || s.contains('chat') || s.contains('opener')) {
      return 'Reference something specific from their profile and end with an easy question. '
          'Example: "Triund or Kedarkantha — which trek would you do again?"';
    }
    if (s.contains('date')) {
      return 'For a first meeting pick a public, daytime place: a café, a book store or a short walk. '
          'Tell a friend where you are going and share your live location.';
    }
    if (s.contains('family') || s.contains('parent')) {
      return 'Be honest about your intent early. When you feel ready, share the relationship with parents '
          'in your own words and let them meet the person gradually.';
    }
    if (s.contains('reject') || s.contains('ghost')) {
      return 'It is not a verdict on you. Compatibility is two-way. Take a break, tweak your photos and bio, '
          'and keep going.';
    }
    return 'Keep it warm and curious: ask open questions, reply within a day, and move to a call '
        'once the chat feels easy.';
  }

  /// Demo stand-in for Bhashini / cloud translation.
  static String translate(String text, String lang) =>
      '[${langNames[lang] ?? lang}] $text';
}
