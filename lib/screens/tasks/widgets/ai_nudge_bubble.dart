import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../services/cognitive_memory_service.dart';

class AINudgeBubble extends StatelessWidget {
  final String text;

  const AINudgeBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF00F2FE)),
              const SizedBox(width: 12),
              Expanded(
                child: MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.5,
                      fontSize: 15,
                    ),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                    tableBorder: TableBorder.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3), width: 1),
                    tableBody: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                    tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                    tableCellsPadding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await CognitiveMemoryService.saveTaskInsightToVault({
                  'insight': text,
                  'type': 'task_suggestion',
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Suggestion saved to Vault! 🧠")),
                  );
                }
              },
              icon: const Icon(Icons.bookmark_add_rounded, color: Color(0xFF00F2FE), size: 18),
              label: const Text(
                "Save to Vault",
                style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
