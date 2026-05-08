import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../models/meeting_brief.dart';
import '../../../services/meeting_brief_service.dart';
import '../../../services/cognitive_memory_service.dart';
import '../../../providers/settings_provider.dart';

class BriefCard extends StatefulWidget {
  final MeetingBrief brief;

  const BriefCard({super.key, required this.brief});

  @override
  State<BriefCard> createState() => _BriefCardState();
}

class _BriefCardState extends State<BriefCard> {
  bool _loading = false;
  String _currentSummary = "";

  @override
  void initState() {
    super.initState();
    _currentSummary = widget.brief.summary;
  }

  Future<void> _handleOpenBrief() async {
    if (_currentSummary.isNotEmpty) {
      _showBriefDialog(context);
      return;
    }

    setState(() => _loading = true);

    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final aiBrief = await MeetingBriefService.generateSingleBrief(
        widget.brief.title,
        settings.selectedModel,
      );

      setState(() {
        _currentSummary = aiBrief;
        _loading = false;
      });

      if (mounted) _showBriefDialog(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("AI Briefing failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE0979).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFE0979).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.videocam_rounded, color: Color(0xFFFE0979), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.brief.title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.brief.time,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _handleOpenBrief,
              icon: _loading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_loading ? "Generating..." : "Open Brief", style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE0979),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBriefDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFFE0979), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFE0979)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "AI Meeting Brief",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.brief.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.brief.time,
                style: const TextStyle(color: Color(0xFFFE0979), fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32),
              MarkdownBody(
                data: _currentSummary,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 16),
                  h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  tableBorder: TableBorder.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3), width: 1),
                  tableBody: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                  tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFE0979)),
                  tableCellsPadding: const EdgeInsets.all(10),
                  listBullet: TextStyle(color: const Color(0xFFFE0979), fontSize: 18),
                  blockquoteDecoration: BoxDecoration(
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(left: BorderSide(color: Color(0xFF00F2FE), width: 4)),
                  ),
                  blockquote: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await CognitiveMemoryService.saveBriefToVault({
                'title': widget.brief.title,
                'time': widget.brief.time,
                'summary': _currentSummary,
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Brief saved to Neural Vault! 🧠")),
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.bookmark_add_rounded, color: Color(0xFF00F2FE)),
            label: const Text(
              "Save to Vault",
              style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Done",
              style: TextStyle(color: Color(0xFFFE0979), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
    );
  }
}
