import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'ocr_service.dart';
import 'vision_agent_service.dart';
import '../../providers/task_provider.dart';
import '../../models/task_item.dart';
import '../../models/vision_insight.dart';
import '../../providers/vision_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/cognitive_dna_service.dart';
import '../../widgets/loading_animations.dart';

class ClawVisionScreen extends StatefulWidget {
  const ClawVisionScreen({super.key});

  @override
  State<ClawVisionScreen> createState() => _ClawVisionScreenState();
}

class _ClawVisionScreenState extends State<ClawVisionScreen> {
  File? image;
  String extractedText = '';
  String aiResult = '';
  bool loading = false;
  bool _isSaved = false;
  VisionMode selectedMode = VisionMode.general;
  final ScrollController _modeScrollController = ScrollController();

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked == null) return;

    setState(() {
      image = File(picked.path);
      loading = true;
      _isSaved = false;
      aiResult = '';
      extractedText = '';
    });

    try {
      final settings = context.read<SettingsProvider>();
      final text = await OCRService.extractText(picked.path);
      final result = await VisionAgentService.analyzeText(text, mode: selectedMode, model: settings.selectedModel);

      setState(() {
        extractedText = text;
        aiResult = result;
        loading = false;
      });
      CognitiveDNAService.logActivity('vision_scan', 'Mode: ${selectedMode.toString().split('.').last}');
    } catch (e) {
      setState(() {
        aiResult = "Error: $e";
        loading = false;
      });
    }
  }

  void _generateTasksFromTimetable() {
    final lines = aiResult.split('\n').where((l) => l.trim().isNotEmpty && (l.contains('•') || l.contains('-'))).toList();
    
    final taskProvider = context.read<TaskProvider>();
    for (var line in lines) {
      final cleanTitle = line.replaceAll(RegExp(r'[•-]'), '').trim();
      if (cleanTitle.isNotEmpty) {
        taskProvider.addTask(TaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + line.length.toString(),
          title: cleanTitle,
          description: "Generated from Timetable Photo",
          priority: "Medium",
          completed: false,
          createdAt: DateTime.now(),
        ));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Successfully generated ${lines.length} tasks!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Darker background like the image
      appBar: AppBar(
        title: const Text("Claw-Vision Synapse", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 40),
            _buildUploadSection(),
            const SizedBox(height: 30),
            if (loading)
              const Center(child: VisionScanLoading()).animate().fadeIn(),
            if (image != null && !loading) _buildResultView(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SingleChildScrollView(
        controller: _modeScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _modeChip("General", VisionMode.general, Icons.auto_awesome),
            _modeChip("Smart Notes", VisionMode.notes, Icons.edit_note),
            _modeChip("Timetable", VisionMode.timetable, Icons.calendar_view_day),
            _modeChip("Research", VisionMode.research, Icons.science),
            _modeChip("Charts", VisionMode.chart, Icons.bar_chart),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _modeChip(String label, VisionMode mode, IconData icon) {
    final isSelected = selectedMode == mode;
    return GestureDetector(
      onTap: () {
        if (selectedMode != mode) {
          setState(() {
            selectedMode = mode;
            image = null;
            aiResult = '';
            extractedText = '';
          });
          
          final index = VisionMode.values.indexOf(mode);
          // Calculate approximate scroll position to center the chip
          // Each chip is roughly 140-160px wide
          const double chipWidth = 150.0; 
          final double screenWidth = MediaQuery.of(context).size.width;
          final double targetScroll = (index * chipWidth) - (screenWidth / 2) + (chipWidth / 2) + 20;

          _modeScrollController.animateTo(
            targetScroll.clamp(0.0, _modeScrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4EE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 8),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.7), 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    String title = "Ready for Scan";
    String subtitle = "Upload a screenshot, photo, or note";
    IconData icon = Icons.cloud_upload_outlined;

    switch (selectedMode) {
      case VisionMode.notes:
        title = "Smart Notes Digitizer";
        subtitle = "Scan handwritten or digital notes";
        icon = Icons.notes_rounded;
        break;
      case VisionMode.timetable:
        title = "Schedule Architect";
        subtitle = "Upload your class or event timetable";
        icon = Icons.calendar_today_rounded;
        break;
      case VisionMode.research:
        title = "Research Insight Engine";
        subtitle = "Upload complex papers or diagrams";
        icon = Icons.science_rounded;
        break;
      case VisionMode.chart:
        title = "Visual Data Analyst";
        subtitle = "Upload charts, graphs or statistics";
        icon = Icons.bar_chart_rounded;
        break;
      default:
        title = "General Vision Scan";
        subtitle = "Analyze any text or visual context";
        icon = Icons.visibility_rounded;
    }

    return Container(
      key: ValueKey(selectedMode),
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 70, color: const Color(0xFF00F2FE)),
          const SizedBox(height: 24),
          Text(
            title, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle, 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16), 
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 35),
          Row(
            children: [
              Expanded(child: _actionButton("Gallery", Icons.image_outlined, () => pickImage(ImageSource.gallery))),
              const SizedBox(width: 16),
              Expanded(child: _actionButton("Camera", Icons.camera_alt_outlined, () => pickImage(ImageSource.camera))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B4EE6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.file(image!, height: 200, width: double.infinity, fit: BoxFit.cover),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        if (aiResult.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFFFE0979)),
                    const SizedBox(width: 10),
                    const Text("AI Synapse Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => RotationTransition(
                          turns: child.key == const ValueKey('saved') 
                            ? anim 
                            : const AlwaysStoppedAnimation(0),
                          child: ScaleTransition(scale: anim, child: child),
                        ),
                        child: _isSaved 
                          ? const Icon(Icons.check_circle_rounded, color: Colors.green, key: ValueKey('saved'))
                          : const Icon(Icons.bookmark_add_rounded, color: Color(0xFF00F2FE), key: ValueKey('unsaved')),
                      ),
                      onPressed: _isSaved ? null : () {
                        context.read<VisionProvider>().saveInsight(
                          VisionInsight(
                            mode: selectedMode.toString().split('.').last,
                            originalText: "", // Removed as requested
                            aiResult: aiResult,
                            timestamp: DateTime.now(),
                            imagePath: image?.path,
                          ),
                        );
                        setState(() => _isSaved = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Vision Insight saved to Vault!"),
                            backgroundColor: const Color(0xFF6B4EE6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(height: 32, color: Colors.white10),
                MarkdownBody(
                  data: aiResult,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
                    h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    blockquoteDecoration: BoxDecoration(
                      color: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: Color(0xFF00F2FE), width: 4)),
                    ),
                    blockquote: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1).fadeIn(),
        ],
      ],
    );
  }
}