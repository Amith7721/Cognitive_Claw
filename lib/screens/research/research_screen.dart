import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../providers/research_provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/ai_loading_widget.dart';

import '../../models/research_paper.dart';
import '../../models/saved_insight.dart';
import '../../widgets/loading_animations.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        context.read<ResearchProvider>().clearResults();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResearchProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Research Papers', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search research papers...',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                prefixIcon: _controller.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () => _controller.clear(),
                    )
                  : const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EE6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) return;
                      provider.searchPapers(_controller.text.trim());
                    },
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF6B4EE6), width: 2),
                ),
              ),
            ).animate().slideY(begin: -0.1, duration: 400.ms).fadeIn(),
          ),

          if (provider.loading)
            const Expanded(child: Center(child: ResearchSearchLoading())),

          if (provider.error != null)
            Expanded(child: Center(child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(provider.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
            ))),

          if (!provider.loading && provider.error == null)
            Expanded(
              child: provider.papers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.papers.length,
                      itemBuilder: (context, index) {
                        final paper = provider.papers[index];
                        return _PaperCard(paper: paper, index: index);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 80,
                color: Color(0xFF6B4EE6),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              "Unlock New Knowledge",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              "Search thousands of ArXiv preprints to fuel your curiosity. From Quantum Physics to Generative AI.",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildChip("Machine Learning"),
                _buildChip("Astrophysics"),
                _buildChip("Cryptography"),
              ],
            ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(
        color: Color(0xFF6B4EE6),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF6B4EE6).withValues(alpha: 0.2)),
      ),
      onPressed: () {
        _controller.text = label;
        Provider.of<ResearchProvider>(context, listen: false).searchPapers(label);
      },
    );
  }
}

class _PaperCard extends StatelessWidget {
  final ResearchPaper paper;
  final int index;

  const _PaperCard({required this.paper, required this.index});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.science_rounded, color: Color(0xFF00F2FE)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    paper.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              paper.summary,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  paper.published,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      context.read<ResearchProvider>().addToHistory(paper);
                      final uri = Uri.parse(paper.link);
                      await launchUrl(uri);
                    },
                    icon: Icon(Icons.open_in_new_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                    label: Text('Open', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1B2E) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: const Color(0xFF00F2FE).withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (mode) async {
                      final researchProvider = context.read<ResearchProvider>();
                      researchProvider.addToHistory(paper);
                      final ai = context.read<AIProvider>();
                      final settings = context.read<SettingsProvider>();
                      String prompt = "";
                      String title = "";
                      switch (mode) {
                        case 'summarize':
                          title = "AI Executive Summary";
                          prompt = "Summarize this research paper simply.\n\nTitle: ${paper.title}\nAbstract: ${paper.summary}\n\nProvide: Main idea, Key contribution, and Applications.";
                          break;
                        case 'simplify':
                          title = "Beginner Explanation";
                          prompt = "Explain this research paper like I am a 10-year-old beginner. Use analogies and very simple language.\n\nTitle: ${paper.title}\nAbstract: ${paper.summary}";
                          break;
                        case 'applications':
                          title = "Real-world Applications";
                          prompt = "Generate 5 concrete, real-world applications for the technology or findings in this paper.\n\nTitle: ${paper.title}\nAbstract: ${paper.summary}";
                          break;
                      }
                      showAILoadingDialog(context, settings.modelName);
                      await ai.generate(
                        prompt: prompt, 
                        model: settings.selectedModel,
                        userName: settings.userName,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context); // close loading dialog
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: const Color(0xFF6B4EE6).withValues(alpha: 0.5)),
                            ),
                            title: Row(
                              children: [
                                const Icon(Icons.psychology_rounded, color: Color(0xFF6B4EE6)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18))),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: MarkdownBody(
                                data: ai.response ?? 'No response',
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6, fontSize: 16),
                                  h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                                  h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                                  listBullet: TextStyle(color: const Color(0xFF6B4EE6), fontSize: 18),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  context.read<ResearchProvider>().saveInsight(
                                    SavedInsight(
                                      paper: paper,
                                      insight: ai.response ?? "",
                                      type: title,
                                      timestamp: DateTime.now(),
                                    ),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Insight saved to Research Vault!"),
                                      backgroundColor: const Color(0xFF6B4EE6),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: const Text("Save to Vault", style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Done", style: TextStyle(color: Color(0xFF6B4EE6), fontSize: 16, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms);
                        },
                      );
                    },
                    offset: const Offset(0, -180),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'summarize',
                        child: Row(
                          children: [
                            Icon(Icons.summarize_rounded, color: Color(0xFF6B4EE6)),
                            SizedBox(width: 10),
                            Text("Concise Summary"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'simplify',
                        child: Row(
                          children: [
                            Icon(Icons.child_care_rounded, color: Color(0xFFFE0979)),
                            SizedBox(width: 10),
                            Text("Simplify (Beginner)"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'applications',
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent),
                            SizedBox(width: 10),
                            Text("Generate Applications"),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4EE6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('AI Agent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_drop_up, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, delay: Duration(milliseconds: 100 * index)).fadeIn();
  }
}
