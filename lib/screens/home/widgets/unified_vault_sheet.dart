import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../research/research_history_screen.dart';
import '../../../features/claw_vision/vision_history_screen.dart';
import '../../vaults/briefs_vault_screen.dart';
import '../../vaults/tasks_vault_screen.dart';

class UnifiedVaultSheet extends StatelessWidget {
  const UnifiedVaultSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: Color(0xFF6B4EE6), size: 32),
              const SizedBox(width: 12),
              Text(
                "Neural Memory Vaults",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Access all your cross-modal cognitive memories.",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildVaultItem(
            context,
            "Research Vault",
            "Academic papers & AI synthesized knowledge.",
            Icons.history_edu_rounded,
            const Color(0xFF6B4EE6),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResearchHistoryScreen())),
          ),
          _buildVaultItem(
            context,
            "Vision Vault",
            "Visual memory logs & OCR analysis history.",
            Icons.history_toggle_off_rounded,
            const Color(0xFFFE0979),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionHistoryScreen())),
          ),
          _buildVaultItem(
            context,
            "Meeting Brief Vault",
            "Saved AI-generated summaries of your meetings.",
            Icons.auto_awesome_rounded,
            const Color(0xFF00F2FE),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BriefsVaultScreen())),
          ),
          _buildVaultItem(
            context,
            "AI Task Vault",
            "Archived task insights & productivity logs.",
            Icons.task_alt_rounded,
            const Color(0xFF4CAF50),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksVaultScreen())),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVaultItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
