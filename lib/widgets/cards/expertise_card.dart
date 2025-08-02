import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpertiseCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final int index;
  final VoidCallback onTap;

  const ExpertiseCard({
    super.key,
    required this.card,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800 + (index * 150)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: card['gradient'],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (card['gradient'][0] as Color).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    if (card['shimmer'])
                      BoxShadow(
                        color: (card['accent'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with background
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          card['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Title - prevent overflow
                      Text(
                        card['title'],
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Details tags - prevent overflow
                      Text(
                        card['details'],
                        maxLines: 2,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
