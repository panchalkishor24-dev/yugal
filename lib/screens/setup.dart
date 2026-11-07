import 'package:flutter/material.dart';
import '../theme.dart';
import '../data.dart';
import '../ai.dart';
import '../widgets.dart';
import 'home.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _name = TextEditingController();
  final _job = TextEditingController();
  final _edu = TextEditingController();
  final _community = TextEditingController();
  final _caste = TextEditingController();
  final _bio = TextEditingController();

  double _age = 28;
  double _height = 170;
  double _weight = 65;
  bool _writing = false;

  String _income = 'Prefer not to say';
  String _religion = 'Prefer not to say';
  String _diet = 'Vegetarian';
  String _smoke = 'Never';
  String _drink = 'Never';
  String _fitness = 'Active';
  final Set<String> _goals = {'Long-term'};
  final Set<String> _interests = {};

  static const _incomes = ['Prefer not to say', '< ₹5L', '₹5–10L', '₹10–25L', '₹25–50L', '₹50L+'];
  static const _religions = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Jain', 'Buddhist', 'Other', 'Prefer not to say'];
  static const _diets = ['Vegetarian', 'Eggetarian', 'Non-veg', 'Vegan', 'Jain'];
  static const _habit = ['Never', 'Socially', 'Regularly'];
  static const _fit = ['Casual', 'Active', 'Athlete'];
  static const _goalOpts = ['Marriage', 'Long-term', 'Friendship', 'Casual dating'];
  static const _interestOpts = [
    'Travel', 'Music', 'Movies', 'Cricket', 'Cooking', 'Fitness', 'Reading',
    'Photography', 'Trekking', 'Yoga', 'Gaming', 'Food', 'Dance', 'Startups',
    'Spirituality', 'Art', 'Pets',
  ];

  @override
  void dispose() {
    for (final c in [_name, _job, _edu, _community, _caste, _bio]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _aiBio() async {
    setState(() => _writing = true);
    final text = await AiService.writeBio(
      name: _name.text,
      job: _job.text,
      interests: _interests,
      goals: _goals,
    );
    if (!mounted) return;
    setState(() {
      _bio.text = text;
      _writing = false;
    });
  }

  void _finish() {
    if (_name.text.trim().isEmpty) {
      snack(context, 'Please enter your name');
      return;
    }
    Me.name = _name.text.trim();
    Me.age = _age.round();
    Me.job = _job.text.trim();
    Me.education = _edu.text.trim();
    Me.religion = _religion;
    Me.diet = _diet;
    Me.bio = _bio.text.trim();
    Me.interests = {..._interests};
    Me.goals = {..._goals};
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (r) => false,
    );
  }

  Widget _field(TextEditingController c, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _single(List<String> opts, String value, void Function(String) set) {
    return ChipGroup(
      options: opts,
      selected: {value},
      onTap: (v) => setState(() => set(v)),
    );
  }

  Widget _slider(String label, double v, double min, double max, String unit,
      void Function(double) set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${v.round()} $unit',
            style: TextStyle(color: context.ink, fontWeight: FontWeight.w600)),
        Slider(
          value: v,
          min: min,
          max: max,
          activeColor: C.saffron,
          onChanged: (x) => setState(() => set(x)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: context.surf,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.line),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: C.saffron, size: 30),
                  const SizedBox(width: 12),
                  Text('Add photos & a short video\n(demo: skipped)',
                      style: TextStyle(color: context.sub, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field(_name, 'Your name'),
            _slider('Age', _age, 21, 45, 'yrs', (x) => _age = x),
            _field(_job, 'Occupation'),
            _field(_edu, 'Education'),
            const SectionLabel('Income range (optional)'),
            _single(_incomes, _income, (v) => _income = v),
            const SectionLabel('Religion'),
            _single(_religions, _religion, (v) => _religion = v),
            const SizedBox(height: 12),
            _field(_community, 'Community'),
            _field(_caste, 'Caste (optional)'),
            const SectionLabel('Diet'),
            _single(_diets, _diet, (v) => _diet = v),
            const SectionLabel('Smoking'),
            _single(_habit, _smoke, (v) => _smoke = v),
            const SectionLabel('Drinking'),
            _single(_habit, _drink, (v) => _drink = v),
            const SectionLabel('Body & fitness'),
            _slider('Height', _height, 140, 205, 'cm', (x) => _height = x),
            _slider('Weight (optional)', _weight, 40, 130, 'kg', (x) => _weight = x),
            _single(_fit, _fitness, (v) => _fitness = v),
            const SectionLabel('I am looking for'),
            ChipGroup(
              options: _goalOpts,
              selected: _goals,
              onTap: (v) => setState(() {
                if (!_goals.remove(v)) _goals.add(v);
              }),
            ),
            const SectionLabel('Interests & hobbies'),
            ChipGroup(
              options: _interestOpts,
              selected: _interests,
              onTap: (v) => setState(() {
                if (!_interests.remove(v)) _interests.add(v);
              }),
            ),
            const SectionLabel('About me'),
            _field(_bio, 'Write a short bio', lines: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _writing ? null : _aiBio,
                icon: _writing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_writing ? 'Writing…' : 'Write with AI'),
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(label: 'Finish & start matching', onTap: _finish),
          ],
        ),
      ),
    );
  }
}
