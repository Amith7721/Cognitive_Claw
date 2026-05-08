import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'loading_animations.dart';

class AILoadingWidget extends StatelessWidget {
  final String modelName;
  const AILoadingWidget({super.key, required this.modelName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D2E),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrainPulseLoading(message: "Generating Neural Brief..."),
            const SizedBox(height: 20),
            Text(
              "Engine: $modelName",
              style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
    );
  }
}

void showAILoadingDialog(BuildContext context, String modelName) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AILoadingWidget(modelName: modelName),
    ),
  );
}
