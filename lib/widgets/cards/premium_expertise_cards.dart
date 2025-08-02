import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expertise_card.dart';

class PremiumExpertiseCards extends StatelessWidget {
  final VoidCallback onCardTap;
  
  const PremiumExpertiseCards({
    super.key,
    required this.onCardTap,
  });

  static final List<Map<String, dynamic>> expertiseCards = [
    {
      'icon': Icons.auto_awesome,
      'title': 'Creative Synthesis',
      'subtitle': 'Merge ideas across disciplines to create breakthrough concepts',
      'details': 'Poetry • Storytelling • Ideation • Innovation',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'accent': Color(0xFF9D50BB),
      'shimmer': true,
    },
    {
      'icon': Icons.psychology,
      'title': 'Deep Analysis',
      'subtitle': 'Unpack complex systems and reveal hidden patterns',
      'details': 'Research • Logic • Strategy • Insights',
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
      'accent': Color(0xFF06D6A0),
      'shimmer': false,
    },
    {
      'icon': Icons.integration_instructions,
      'title': 'Technical Mastery',
      'subtitle': 'Engineer elegant solutions to sophisticated problems',
      'details': 'Code • Architecture • Debugging • Optimization',
      'gradient': [Color(0xFFfc466b), Color(0xFF3f5efb)],
      'accent': Color(0xFF5B63F7),
      'shimmer': true,
    },
    {
      'icon': Icons.trending_up,
      'title': 'Strategic Vision',
      'subtitle': 'Navigate complexity with clarity and foresight',
      'details': 'Planning • Growth • Innovation • Leadership',
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'accent': Color(0xFFF72585),
      'shimmer': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: expertiseCards.length,
      itemBuilder: (context, index) {
        return ExpertiseCard(
          card: expertiseCards[index],
          index: index,
          onTap: () {
            HapticFeedback.lightImpact();
            onCardTap();
          },
        );
      },
    );
  }
}
