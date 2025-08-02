class GreetingService {
  static const String defaultUsername = "AK";
  
  // Highly personalized greeting system with creative variations
  static final List<Map<String, String>> _personalizedGreetings = [
    // Early morning (0-6)
    {"greeting": "Still chasing ideas", "emoji": "🌙", "subtitle": "The best insights come in quiet hours"},
    {"greeting": "Night owl mode", "emoji": "🦉", "subtitle": "When the world sleeps, creativity awakens"},
    {"greeting": "Burning the midnight oil", "emoji": "✨", "subtitle": "Let's make this session count"},
    
    // Morning (6-12)
    {"greeting": "Fresh morning energy", "emoji": "☀️", "subtitle": "Ready to conquer new challenges"},
    {"greeting": "Rise and innovate", "emoji": "🚀", "subtitle": "The day is full of possibilities"},
    {"greeting": "Morning spark", "emoji": "⚡", "subtitle": "What breakthrough awaits us today?"},
    {"greeting": "Dawn of possibilities", "emoji": "🌅", "subtitle": "Let's start something extraordinary"},
    
    // Afternoon (12-17)
    {"greeting": "Midday momentum", "emoji": "🌤️", "subtitle": "Perfect time for deep thinking"},
    {"greeting": "Afternoon inspiration", "emoji": "💡", "subtitle": "Ready to solve complex puzzles"},
    {"greeting": "Peak performance hours", "emoji": "⭐", "subtitle": "Your mind is sharp and focused"},
    
    // Evening (17-21)
    {"greeting": "Golden hour thinking", "emoji": "🌅", "subtitle": "End the day with something meaningful"},
    {"greeting": "Evening excellence", "emoji": "🎯", "subtitle": "Time for refined solutions"},
    {"greeting": "Twilight wisdom", "emoji": "🌆", "subtitle": "Let's craft something beautiful"},
    
    // Night (21-24)
    {"greeting": "Late night brilliance", "emoji": "🌟", "subtitle": "When focus meets inspiration"},
    {"greeting": "Nocturnal genius", "emoji": "🌌", "subtitle": "The quiet hours spark innovation"},
    {"greeting": "Midnight mastery", "emoji": "🎭", "subtitle": "Ready for some deep work"},
  ];

  static final List<String> _sophisticatedPrompts = [
    "What extraordinary idea shall we explore today?",
    "Ready to dive deep into complex problems?",
    "Let's create something remarkable together",
    "What fascinating challenge awaits us?",
    "Time to transform curiosity into insight",
    "Ready to push the boundaries of possibility?",
    "What intricate puzzle can I help solve?",
    "Let's craft solutions that matter",
    "Ready to explore uncharted territories?",
    "What ambitious project shall we tackle?"
  ];

  static Map<String, String> getCurrentGreeting({String username = defaultUsername}) {
    final currentTimeOfDay = DateTime.now().hour;
    
    final timeFilteredGreetings = _personalizedGreetings.where((g) {
      if (currentTimeOfDay < 6) return ["🌙", "🦉", "✨"].contains(g["emoji"]);
      if (currentTimeOfDay < 12) return ["☀️", "🚀", "⚡", "🌅"].contains(g["emoji"]);
      if (currentTimeOfDay < 17) return ["🌤️", "💡", "⭐"].contains(g["emoji"]);
      if (currentTimeOfDay < 21) return ["🌅", "🎯", "🌆"].contains(g["emoji"]);
      return ["🌟", "🌌", "🎭"].contains(g["emoji"]);
    }).toList();
    
    if (timeFilteredGreetings.isEmpty) {
      return _personalizedGreetings.first;
    }
    
    // Use minute for variation within the same time period
    return timeFilteredGreetings[DateTime.now().minute % timeFilteredGreetings.length];
  }

  static String getTimeBasedGreeting({String username = defaultUsername}) {
    final greeting = getCurrentGreeting(username: username);
    return "${greeting["greeting"]!}, $username ${greeting["emoji"]!}";
  }

  static String getContextualSubtitle({String username = defaultUsername}) {
    final greeting = getCurrentGreeting(username: username);
    return greeting["subtitle"]!;
  }

  static String getSophisticatedPrompt(int index) {
    return _sophisticatedPrompts[index % _sophisticatedPrompts.length];
  }

  static int get promptCount => _sophisticatedPrompts.length;
}
