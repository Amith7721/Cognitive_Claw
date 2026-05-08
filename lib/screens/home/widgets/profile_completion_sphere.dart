import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../main.dart'; // To access MainShell.switchTab

class ProfileCompletionSphere extends StatelessWidget {
  const ProfileCompletionSphere({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    if (settings.isProfileComplete) return const SizedBox.shrink();

    final percentage = settings.profileCompletion;

    return GestureDetector(
      onTap: () {
        // Switch to the Settings tab (index 4) in the MainShell
        MainShell.switchTab(4);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFE0979).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sphere Percentage Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFE0979)),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFE0979).withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${(percentage * 100).toInt()}%",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Neural Identity Incomplete",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "The AI needs more data about you to unlock full agentic potential.",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text(
                        "COMPLETE PROFILE",
                        style: TextStyle(color: Color(0xFFFE0979), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFE0979), size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideX(begin: -0.1).fadeIn(),
    );
  }
}
