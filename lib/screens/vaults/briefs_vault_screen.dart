import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../../services/cognitive_memory_service.dart';

class BriefsVaultScreen extends StatefulWidget {
  const BriefsVaultScreen({super.key});

  @override
  State<BriefsVaultScreen> createState() => _BriefsVaultScreenState();
}

class _BriefsVaultScreenState extends State<BriefsVaultScreen> {
  late List<Map<dynamic, dynamic>> savedBriefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    savedBriefs = CognitiveMemoryService.getSavedBriefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Meeting Brief Vault"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: savedBriefs.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: savedBriefs.length,
              itemBuilder: (context, index) {
                final brief = savedBriefs[index];
                return _buildDismissibleCard(context, brief, index);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text("No Saved Briefs", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          const Text("Save briefings from your schedule to see them here.", style: TextStyle(color: Colors.grey)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, Map<dynamic, dynamic> brief, int index) {
    return Dismissible(
      key: Key(brief['saved_at'] + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
      ),
      onDismissed: (direction) async {
        await CognitiveMemoryService.deleteBriefFromVault(index);
        setState(() {
          savedBriefs.removeAt(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Brief deleted from Vault"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: _buildBriefCard(context, brief, index),
    );
  }

  Widget _buildBriefCard(BuildContext context, Map<dynamic, dynamic> brief, int index) {
    final savedAt = DateTime.parse(brief['saved_at']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bookmark_rounded, color: Color(0xFF00F2FE)),
        ),
        title: Text(
          brief['title'] ?? "Meeting Brief",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Saved on ${DateFormat('MMM dd, yyyy').format(savedAt)}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                MarkdownBody(
                  data: brief['summary'] ?? "",
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 15),
                    h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    blockquoteDecoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: Color(0xFF00F2FE), width: 4)),
                    ),
                    blockquote: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * index)).fadeIn();
  }
}
