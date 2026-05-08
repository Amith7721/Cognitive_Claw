import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/task_provider.dart';
import '../../providers/research_provider.dart';
import '../../providers/ai_provider.dart';

import '../../models/task_item.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/research_paper.dart';

import '../../services/calendar_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/ai_loading_widget.dart';
import '../../services/openclaw_agent_service.dart';
import '../../services/heartbeat_service.dart';
import '../../services/heartbeat_engine.dart';
import '../../services/cognitive_memory_service.dart';
import '../../features/claw_vision/claw_vision_screen.dart';
import '../../features/claw_vision/vision_history_screen.dart';
import '../briefs/briefs_screen.dart';
import '../research/research_screen.dart';
import '../research/research_history_screen.dart';
import 'widgets/analytics_dashboard.dart';
import 'widgets/unified_vault_sheet.dart';
import '../../services/voice_service.dart';
import '../research/widgets/paper_card.dart';
import 'widgets/meeting_banner.dart';
import 'widgets/task_preview_card.dart';
import 'widgets/context_graph_card.dart';
import 'widgets/cognitive_dna_card.dart';
import 'widgets/profile_completion_sphere.dart';
import '../../providers/voice_provider.dart';
import '../../services/cognitive_dna_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  bool _isAiSpeaking = false;

  String meetingTitle = "No upcoming meetings";
  String meetingTime = "";
  int meetingAttendees = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboard();
    });
  }

  Future<void> loadDashboard() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final researchProvider = Provider.of<ResearchProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    try {
      await taskProvider.loadTasks();
      // Research doesn't load automatically anymore
    } catch (e) {
      debugPrint(e.toString());
    }

    // Show the dashboard immediately
    setState(() {
      _loading = false;
    });

    // Update Heartbeat (Layer 1: Context Aggregator)
    HeartbeatService.updateHeartbeat(taskProvider, researchProvider);

    // Start Heartbeat Autonomous Engine (Layer 3: Orchestration)
    HeartbeatAutonomousEngine.start(taskProvider, researchProvider);

    // Load AI advice in the background (no blocking)
    OpenClawAgentService.generateDailyBrief(
      model: settings.selectedModel,
      userName: settings.userName,
      userRole: settings.userRole,
      userGoals: settings.userGoals,
      userSkills: settings.userSkills,
      preferredTone: settings.preferredTone,
    ).then((brief) {
      if (mounted) aiProvider.setResponse(brief);
    }).catchError((e) {
      debugPrint('AI Brief error: $e');
    });

    // Load calendar in background (no blocking)
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    try {
      final signedIn = await CalendarService.isSignedIn();
      if (signedIn) {
        final events = await CalendarService.getUpcomingEvents();
        if (events.isNotEmpty && mounted) {
          final event = events.first;
          setState(() {
            meetingTitle = event.title;
            meetingTime = event.startTime.toString();
            meetingAttendees = event.attendeeNames.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Calendar error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final researchProvider = Provider.of<ResearchProvider>(context);

    final aiProvider = Provider.of<AIProvider>(context);

    final tasks = taskProvider.tasks;
    final papers = researchProvider.papers;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Cognitive Claw", style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.bubble_chart_rounded,
        activeIcon: Icons.close_rounded,
        backgroundColor: const Color(0xFF6B4EE6),
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.visibility_rounded, color: Colors.white),
            label: 'Claw-Vision Synapse',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            backgroundColor: const Color(0xFFFE0979),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClawVisionScreen()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.mic_rounded, color: Colors.white),
            label: 'Voice Assistant',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            backgroundColor: const Color(0xFF6B4EE6),
            onTap: () async {
              final voiceProv = Provider.of<VoiceProvider>(context, listen: false);
              bool dialogClosedManually = false;
              showDialog(
                context: context,
                barrierDismissible: true, // Allow tapping outside to cancel
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                            onPressed: () {
                              dialogClosedManually = true;
                              Navigator.pop(context, 'cancel');
                            },
                          ),
                        ],
                      ),
                      const Icon(Icons.mic_rounded, color: Color(0xFF6B4EE6), size: 60)
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 600.ms, curve: Curves.easeInOut)
                          .then()
                          .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 600.ms),
                      const SizedBox(height: 20),
                      Text("Neural Listening...", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text("Speak your command now", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ).then((_) => dialogClosedManually = true); // Mark as closed regardless of how it closed

              final speech = await Future.delayed(const Duration(milliseconds: 500), () => VoiceService.listen());
              
              // ONLY pop if it wasn't already closed by the user tapping outside or the X button
              if (mounted && !dialogClosedManually) {
                Navigator.pop(context); 
              }
              
              if (speech.isEmpty) {
                if (mounted && !dialogClosedManually) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("I did not recognize anything. Please try again."),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                }
                return;
              }
              
              // Activate global subtitles and glow
              voiceProv.startSpeaking(speech);
              CognitiveDNAService.logActivity('voice_command', 'Query: $speech');

              // Process via our Agent Service
              final aiResponse = await OpenClawAgentService.analyzeBehavior(
                logs: [{'type': 'voice_command', 'query': speech, 'time': DateTime.now().toIso8601String()}],
                model: Provider.of<SettingsProvider>(context, listen: false).selectedModel,
                userName: Provider.of<SettingsProvider>(context, listen: false).userName,
                userRole: Provider.of<SettingsProvider>(context, listen: false).userRole,
                userGoals: Provider.of<SettingsProvider>(context, listen: false).userGoals,
                preferredTone: Provider.of<SettingsProvider>(context, listen: false).preferredTone,
              );
              
              voiceProv.updateAiSpeech(aiResponse);
              await VoiceService.speak(aiResponse);
              voiceProv.stopSpeaking();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.inventory_2_rounded, color: Colors.white),
            label: 'Memory Vault',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            backgroundColor: const Color(0xFF6B4EE6),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const UnifiedVaultSheet(),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.analytics_rounded, color: Colors.white),
            label: 'AI Analytics',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            backgroundColor: const Color(0xFFFE0979),
            onTap: () => _showAnalyticsDashboard(context),
          ),
        ],
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      body: _loading
          ? AILoadingWidget(modelName: settings.modelName)
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      buildWelcomeCard().animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(),

                      const SizedBox(height: 20),

                      const ProfileCompletionSphere(),

                      const SizedBox(height: 20),

                      const CognitiveDNACard().animate().slideY(begin: 0.1, duration: 400.ms, delay: 50.ms).fadeIn(),

                      const SizedBox(height: 20),

                      const SizedBox(height: 10),

                      buildMeetingCard().animate().slideX(begin: -0.1, duration: 400.ms, delay: 100.ms).fadeIn(),

                      const SizedBox(height: 20),

                      buildAiAdviceCard(
                        aiProvider.response ?? "No AI advice available",
                      ).animate().slideX(begin: 0.1, duration: 400.ms, delay: 200.ms).fadeIn(),

                      const SizedBox(height: 20),

                      buildStatsSection(tasks, researchProvider.history).animate().slideY(begin: 0.1, duration: 400.ms, delay: 300.ms).fadeIn(),

                      const SizedBox(height: 20),

                      const ContextGraphCard().animate().slideY(begin: 0.1, duration: 400.ms, delay: 350.ms).fadeIn(),

                      const SizedBox(height: 20),

                      // OpenClaw Agent Status Card
                      _buildOpenClawStatusCard().animate().slideY(begin: 0.1, duration: 400.ms, delay: 375.ms).fadeIn(),

                      const SizedBox(height: 20),

                      buildRecentTasks(tasks).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 20),

                      buildResearchPreview(papers, researchProvider.history).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4EE6), Color(0xFF00F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F2FE).withValues(alpha: 0.4),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 18, letterSpacing: 1.2),
          ),
          SizedBox(height: 10),
          Text(
            "Your AI workspace is active",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMeetingCard() {
    return MeetingBanner(
      title: meetingTitle,
      time: meetingTime,
      attendees: meetingAttendees,
    );
  }

  Widget buildAiAdviceCard(String advice) {
    return GestureDetector(
      onTap: () => _showFullAiAdvice(advice),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withValues(alpha: 0.05),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF00F2FE)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "AI Productivity Advice",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              advice.replaceAll(RegExp(r'[#*`|_-]'), '').replaceAll(RegExp(r'\n+'), ' ').trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullAiAdvice(String advice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF00F2FE), size: 32),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Cognitive Insights",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: advice,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(fontSize: 19, height: 1.7, color: Theme.of(context).textTheme.bodyMedium?.color),
                        h1: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                        h2: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                        h3: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                        tableBorder: TableBorder.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3), width: 1),
                        tableBody: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                        tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                        tableCellsPadding: const EdgeInsets.all(12),
                        listBullet: TextStyle(color: const Color(0xFF00F2FE), fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.memory, color: Color(0xFF6B4EE6), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "Neural Memory Vault",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...CognitiveMemoryService.getHabits().map((habit) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: Colors.greenAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    habit,
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          ...CognitiveMemoryService.getPatterns().map((pattern) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.psychology_alt_outlined, size: 14, color: Colors.blueAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    pattern,
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EE6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Got it, thanks!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatsSection(List<TaskItem> tasks, List<ResearchPaper> papers) {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            title: "Tasks",
            value: tasks.length.toString(),
            icon: Icons.task_alt_rounded,
            color: const Color(0xFFFE0979),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: buildStatCard(
            title: "Research",
            value: papers.length.toString(),
            icon: Icons.science_rounded,
            color: const Color(0xFF6B4EE6),
          ),
        ),
      ],
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 38),
          SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildRecentTasks(List<TaskItem> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Tasks",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 15),

        if (tasks.isEmpty)
          Text(
            "No tasks available",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),

        ...([...tasks]..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            .take(3)
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => TaskPreviewCard(task: entry.value).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * entry.key)),
            ),
      ],
    );
  }

  Widget buildResearchPreview(List<ResearchPaper> papers, List<ResearchPaper> history) {
    final displayPapers = history.isNotEmpty ? history : papers;
    final title = history.isNotEmpty ? "Latest Research" : "Suggested Research";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        if (displayPapers.isEmpty)
          Text(
            "No research papers found",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),

        ...displayPapers
            .take(2)
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => PaperCard(paper: entry.value).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * entry.key)),
            ),
      ],
    );
  }

  Widget _buildOpenClawStatusCard() {
    final modules = [
      {'name': 'Layer 1: Context Aggregator', 'desc': 'HEARTBEAT.md Dynamic Graph', 'icon': Icons.monitor_heart_rounded},
      {'name': 'Layer 2: Memory Engine', 'desc': 'Agentic Controller & State', 'icon': Icons.psychology_rounded},
      {'name': 'Adaptive Eviction', 'desc': 'Inactive Memory Cleanup', 'icon': Icons.cleaning_services_rounded},
      {'name': 'Local-first Sync', 'desc': 'Zero Cloud Latency', 'icon': Icons.bolt_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_rounded, color: Color(0xFF6B4EE6), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OpenClaw Architecture",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Multi-Layer Orchestration Active",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...modules.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(m['icon'] as IconData, color: const Color(0xFF00F2FE), size: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['name'] as String,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        m['desc'] as String,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showAnalyticsDashboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AnalyticsDashboard(),
    );
  }
}
