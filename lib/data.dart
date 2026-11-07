import 'package:flutter/material.dart';

class Person {
  final int id;
  final String name;
  final int age;
  final String city;
  final int km;
  final String job;
  final String education;
  final String religion;
  final String community;
  final String diet;
  final String height;
  final String bio;
  final List<String> interests;
  final int compat;
  final bool verified;
  final bool online;
  final bool trending;
  final bool isNew;
  final Color c1;
  final Color c2;
  final String emoji;

  const Person({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.km,
    required this.job,
    required this.education,
    required this.religion,
    required this.community,
    required this.diet,
    required this.height,
    required this.bio,
    required this.interests,
    required this.compat,
    this.verified = true,
    this.online = false,
    this.trending = false,
    this.isNew = false,
    required this.c1,
    required this.c2,
    required this.emoji,
  });
}

/// Sample profiles for the demo build. In production these come from the
/// recommendation API (`GET /v1/discover`).
const List<Person> people = [
  Person(
    id: 1,
    name: 'Priya Sharma',
    age: 27,
    city: 'Mumbai',
    km: 8,
    job: 'UX Designer',
    education: 'NID Ahmedabad',
    religion: 'Hindu',
    community: 'Brahmin',
    diet: 'Vegetarian',
    height: "5'4\"",
    bio:
        "Design nerd who runs on chai, Hindustani classical and weekend treks. Looking for someone who matches my energy and loves a good plan B.",
    interests: ['Design', 'Trekking', 'Classical music', 'Photography', 'Yoga'],
    compat: 94,
    online: true,
    trending: true,
    c1: Color(0xFFFF6B2B),
    c2: Color(0xFFE8356D),
    emoji: '🎨',
  ),
  Person(
    id: 2,
    name: 'Ananya Reddy',
    age: 29,
    city: 'Hyderabad',
    km: 14,
    job: 'Software Engineer',
    education: 'IIT Bombay',
    religion: 'Hindu',
    community: 'Reddy',
    diet: 'Non-veg',
    height: "5'3\"",
    bio:
        "Code by day, Bharatanatyam by evening. Searching for a thoughtful partner who values culture and ambition equally.",
    interests: ['Coding', 'Dance', 'Biryani', 'Chess', 'Travel'],
    compat: 89,
    online: true,
    c1: Color(0xFF7C3AED),
    c2: Color(0xFFE8356D),
    emoji: '💃',
  ),
  Person(
    id: 3,
    name: 'Kavya Nair',
    age: 26,
    city: 'Bengaluru',
    km: 22,
    job: 'Product Manager',
    education: 'IIM Calcutta',
    religion: 'Hindu',
    community: 'Nair',
    diet: 'Vegetarian',
    height: "5'5\"",
    bio:
        "Foodie, bookworm, podcast addict. Good conversations beat everything. Debate me on the best dosa in Bengaluru.",
    interests: ['Reading', 'Food', 'Podcasts', 'Running', 'Films'],
    compat: 91,
    isNew: true,
    c1: Color(0xFF0EA5A4),
    c2: Color(0xFF2563EB),
    emoji: '📚',
  ),
  Person(
    id: 4,
    name: 'Rhea Mehta',
    age: 28,
    city: 'Delhi',
    km: 31,
    job: 'Architect',
    education: 'SPA Delhi',
    religion: 'Jain',
    community: 'Shvetambara',
    diet: 'Jain',
    height: "5'6\"",
    bio:
        "I design spaces that breathe and hope to build a relationship that does too. Dog mum. Rom-com loyalist.",
    interests: ['Architecture', 'Art', 'Dogs', 'Films', 'Cooking'],
    compat: 87,
    online: true,
    c1: Color(0xFFF59E0B),
    c2: Color(0xFFEA580C),
    emoji: '🏛️',
  ),
  Person(
    id: 5,
    name: 'Arjun Deshmukh',
    age: 30,
    city: 'Pune',
    km: 6,
    job: 'Entrepreneur',
    education: 'COEP Pune',
    religion: 'Hindu',
    community: 'Maratha',
    diet: 'Non-veg',
    height: "5'10\"",
    bio:
        "Building a D2C brand, breaking a sweat at 6 AM. Family first, startups second, cricket always.",
    interests: ['Startups', 'Cricket', 'Fitness', 'Travel', 'Cooking'],
    compat: 85,
    trending: true,
    c1: Color(0xFF16A34A),
    c2: Color(0xFF0F766E),
    emoji: '🚀',
  ),
  Person(
    id: 6,
    name: 'Imran Khan',
    age: 31,
    city: 'Lucknow',
    km: 40,
    job: 'Doctor (MBBS, MD)',
    education: 'KGMU Lucknow',
    religion: 'Muslim',
    community: 'Sunni',
    diet: 'Non-veg',
    height: "5'11\"",
    bio:
        "Physician who loves old Hindi songs, long drives and kebabs from the right gali. Looking for a kind, curious partner.",
    interests: ['Music', 'Driving', 'Food', 'Reading', 'Football'],
    compat: 82,
    online: true,
    trending: true,
    c1: Color(0xFF2563EB),
    c2: Color(0xFF7C3AED),
    emoji: '🩺',
  ),
  Person(
    id: 7,
    name: 'Simran Kaur',
    age: 25,
    city: 'Chandigarh',
    km: 55,
    job: 'Fashion Designer',
    education: 'NIFT Delhi',
    religion: 'Sikh',
    community: 'Jat Sikh',
    diet: 'Non-veg',
    height: "5'5\"",
    bio:
        "Phulkari prints, punjabi pop and parathas at 2 PM. Looking for someone who can make me laugh louder than my dhol playlist.",
    interests: ['Fashion', 'Music', 'Dance', 'Food', 'Art'],
    compat: 88,
    isNew: true,
    c1: Color(0xFFDB2777),
    c2: Color(0xFFF59E0B),
    emoji: '🧵',
  ),
  Person(
    id: 8,
    name: 'Meera Iyer',
    age: 32,
    city: 'Chennai',
    km: 70,
    job: 'Data Scientist',
    education: 'IISc Bengaluru',
    religion: 'Hindu',
    community: 'Iyer',
    diet: 'Vegetarian',
    height: "5'4\"",
    bio:
        "Carnatic music, filter coffee and fascinating datasets. Marriage-minded, family-oriented and fiercely independent.",
    interests: ['Carnatic music', 'Coffee', 'Data', 'Yoga', 'Travel'],
    compat: 90,
    trending: true,
    c1: Color(0xFF0891B2),
    c2: Color(0xFF4F46E5),
    emoji: '🎶',
  ),
];

/// The signed-in user's local state for the demo build.
class Me {
  static String name = 'You';
  static int age = 28;
  static String job = '';
  static String education = '';
  static String religion = 'Prefer not to say';
  static String diet = '';
  static String bio = '';
  static Set<String> interests = {};
  static Set<String> goals = {};
  static int authScore = 40;

  static final ValueNotifier<String> planN = ValueNotifier<String>('Free');
  static String get plan => planN.value;
  static bool get premium => plan != 'Free';

  static int likesLeft = 20;
  static int superLikes = 1;
  static bool incognito = false;
  static bool screenshotAlerts = true;
  static List<String> contacts = ['Mom — +91 98XXXXXX01'];
}
