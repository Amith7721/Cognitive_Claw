import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BrainPulseLoading extends StatelessWidget {
  final String message;
  const BrainPulseLoading({super.key, this.message = "Neural Synthesis in progress..."});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat())
             .scale(begin: const Offset(1, 1), end: const Offset(2, 2), duration: 1.5.seconds, curve: Curves.easeOut)
             .fadeOut(),
            
            const Icon(Icons.psychology_rounded, color: Color(0xFF6B4EE6), size: 50)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: const Color(0xFF00F2FE))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms, curve: Curves.easeInOut)
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 600.ms),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ).animate(onPlay: (c) => c.repeat())
         .shimmer(duration: 2.seconds),
      ],
    );
  }
}

class VisionScanLoading extends StatelessWidget {
  const VisionScanLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.crop_free_rounded, color: Colors.white24, size: 120),
              
              // Scanning Line
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F2FE),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00F2FE).withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat())
                 .moveY(begin: 0, end: 120, duration: 1.5.seconds, curve: Curves.easeInOut)
                 .then()
                 .moveY(begin: 120, end: 0, duration: 1.5.seconds, curve: Curves.easeInOut),
              ),
              
              const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF00F2FE), size: 40)
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms)
                .then()
                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 800.ms),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Analyzing Visual Synapse...",
          style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }
}

class ResearchSearchLoading extends StatelessWidget {
  const ResearchSearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.5), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.menu_book_rounded, color: Color(0xFF6B4EE6), size: 40),
          ),
        ).animate(onPlay: (c) => c.repeat())
         .rotate(begin: 0, end: 1, duration: 2.seconds, curve: Curves.easeInOut)
         .scale(begin: const Offset(1, 1), end: const Offset(0.8, 0.8), duration: 1.seconds)
         .then()
         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 1.seconds),
        
        const SizedBox(height: 24),
        const Text(
          "Scanning Global Knowledge Vaults...",
          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
