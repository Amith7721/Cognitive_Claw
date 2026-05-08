import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../../providers/vision_provider.dart';
import '../../models/vision_insight.dart';

class VisionHistoryScreen extends StatelessWidget {
  const VisionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Vision Vault"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<VisionProvider>(
        builder: (context, provider, child) {
          if (provider.savedInsights.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.savedInsights.length,
            itemBuilder: (context, index) {
              final insight = provider.savedInsights[index];
              return Dismissible(
                key: Key(insight.timestamp.toIso8601String() + index.toString()),
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
                onDismissed: (direction) {
                  provider.deleteInsight(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Vision log deleted from Vault"),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: _buildInsightCard(context, insight, index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            "Vision Vault is Empty",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            "Save AI vision insights to see them here.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildInsightCard(BuildContext context, VisionInsight insight, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE0979).withValues(alpha: 0.1),
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
            color: const Color(0xFFFE0979).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.psychology_rounded, color: Color(0xFFFE0979)),
        ),
        title: Text(
          "Scan Mode: ${insight.mode.toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            DateFormat('MMM dd, yyyy • HH:mm').format(insight.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (insight.imagePath != null && File(insight.imagePath!).existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(insight.imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  "AI SYNPSE RESULT:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFE0979)),
                ),
                const SizedBox(height: 8),
                MarkdownBody(
                  data: insight.aiResult,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 15),
                    h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    tableBorder: TableBorder.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3), width: 1),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * index)).fadeIn();
  }
}
