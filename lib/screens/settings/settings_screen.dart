import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../services/calendar_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final models = {
    'Auto Mode (Recommended)': 'openrouter/free',
    'Fast Mode (Balanced)': 'openai/gpt-oss-20b:free',
    'Smart Mode (Intelligence)': 'z-ai/glm-4.5-air:free',
    'Research Mode (Deep Thinker)': 'openai/gpt-oss-120b:free',
  };

  final Map<String, Map<String, dynamic>> modelMetadata = {
    'openrouter/free': {
      'tag': 'SMART',
      'color': const Color(0xFF00F2FE),
      'icon': Icons.hub_rounded,
      'desc': 'Universal free router. Best AI for any task.'
    },
    'openai/gpt-oss-20b:free': {
      'tag': 'BALANCED',
      'color': Colors.greenAccent,
      'icon': Icons.bolt_rounded,
      'desc': 'Optimal for daily tasks and quick assistance.'
    },
    'z-ai/glm-4.5-air:free': {
      'tag': 'INTELLIGENCE',
      'color': Colors.orangeAccent,
      'icon': Icons.auto_awesome_rounded,
      'desc': 'Advanced multilingual intelligence and reasoning.'
    },
    'openai/gpt-oss-120b:free': {
      'tag': 'RESEARCH',
      'color': const Color(0xFF6B4EE6),
      'icon': Icons.psychology_rounded,
      'desc': 'Maximum power for deep academic analysis.'
    },
  };

  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _goalsController;
  late TextEditingController _skillsController;
  String _selectedTone = "Professional";

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.syncCalendarStatus();
    _nameController = TextEditingController(text: settings.userName);
    _roleController = TextEditingController(text: settings.userRole);
    _goalsController = TextEditingController(text: settings.userGoals);
    _skillsController = TextEditingController(text: settings.userSkills);
    _selectedTone = settings.preferredTone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _goalsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _showProfileEditor() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Neural Identity Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField("Full Name", _nameController, Icons.person),
                const SizedBox(height: 16),
                _buildField("Role / Designation", _roleController, Icons.work),
                const SizedBox(height: 16),
                _buildField("Primary Goals", _goalsController, Icons.flag, maxLines: 2),
                const SizedBox(height: 16),
                _buildField("Key Skills (comma separated)", _skillsController, Icons.star, maxLines: 2),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTone,
                  decoration: InputDecoration(
                    labelText: "AI Response Tone",
                    prefixIcon: const Icon(Icons.psychology_rounded, color: Color(0xFF6B4EE6)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: ["Professional", "Casual", "Motivational", "Academic"]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    setModalState(() => _selectedTone = v!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsProvider>().updateProfile(
                  name: _nameController.text,
                  role: _roleController.text,
                  goals: _goalsController.text,
                  skills: _skillsController.text,
                  tone: _selectedTone,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Identity Profile Synchronized!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EE6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B4EE6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6B4EE6), Color(0xFF00F2FE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.userName.isEmpty ? "Name Not Set" : settings.userName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            settings.userRole.isEmpty ? "No Role Defined" : settings.userRole,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showProfileEditor,
                      icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF6B4EE6), size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildIdentityTag("GOAL", settings.userGoals.isEmpty ? "Set your primary focus" : settings.userGoals, Icons.flag_rounded),
                const SizedBox(height: 10),
                _buildIdentityTag("TONE", settings.preferredTone, Icons.psychology_rounded),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 32),

          Text(
            'Intelligence Orchestration',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 100.ms).fadeIn(),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4EE6).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Processing Modes",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F2FE), fontSize: 14, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                _buildModeGuide("Auto Mode", "Cognitive Claw selects the best AI automatically."),
                _buildModeGuide("Fast Mode", "Faster responses with lightweight reasoning."),
                _buildModeGuide("Smart Mode", "Balanced speed and intelligence."),
                _buildModeGuide("Deep Research Mode", "Advanced reasoning and analysis."),
              ],
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 120.ms).fadeIn(),

          const SizedBox(height: 24),

          Column(
            children: models.entries.map((e) {
              final isSelected = settings.selectedModel == e.value;
              final meta = modelMetadata[e.value]!;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isSelected ? meta['color'].withValues(alpha: 0.1) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? meta['color'].withValues(alpha: 0.5) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    settings.setModel(e.value);
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (meta['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(meta['icon'] as IconData, color: meta['color'] as Color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      e.key.split('(')[0].trim(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isSelected ? meta['color'] as Color : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (meta['color'] as Color).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        meta['tag'] as String,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: meta['color'] as Color, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meta['desc'] as String,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: meta['color'] as Color),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().slideX(begin: 0.1);
            }).toList(),
          ),

          const SizedBox(height: 30),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.notificationsEnabled,
                  activeTrackColor: const Color(0xFF00F2FE).withValues(alpha: 0.3),
                  activeThumbColor: const Color(0xFF00F2FE),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  title: Text(
                    'Notifications',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (v) {
                    settings.toggleNotifications(v);
                  },
                ),
                Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                SwitchListTile(
                  value: settings.isDarkMode,
                  activeTrackColor: const Color(0xFFFE0979).withValues(alpha: 0.3),
                  activeThumbColor: const Color(0xFFFE0979),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (v) {
                    settings.toggleDarkMode(v);
                  },
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 200.ms).fadeIn(),

          const SizedBox(height: 30),

          // Google Calendar Section
          Text(
            'Google Calendar',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 250.ms).fadeIn(),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: settings.calendarConnected
                    ? const Color(0xFF00F2FE).withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              boxShadow: settings.calendarConnected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: settings.calendarConnected
                            ? const Color(0xFF00F2FE).withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: settings.calendarConnected ? const Color(0xFF00F2FE) : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Calendar',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: settings.calendarConnected ? Colors.greenAccent : Colors.redAccent,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                settings.calendarConnected ? 'Connected' : 'Not Connected',
                                style: TextStyle(
                                  color: settings.calendarConnected ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                settings.calendarConnected
                    ? SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await CalendarService.signOut();
                            await settings.syncCalendarStatus();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Google Calendar disconnected.'),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.link_off_rounded, size: 20),
                          label: const Text('Disconnect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await CalendarService.signInWithGoogle();
                            await settings.syncCalendarStatus();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Google Calendar connected!' : 'Sign-in failed.'),
                                  backgroundColor: success ? const Color(0xFF00F2FE) : Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F2FE),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.calendar_today_rounded, size: 20),
                          label: const Text('Connect Google Calendar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
              ],
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 300.ms).fadeIn(),

          const SizedBox(height: 30),

          Container(
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
                  color: const Color(0xFF00F2FE).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Production Ready',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '• OpenClaw Agent Orchestration\n'
                  '• Live Google Calendar Sync\n'
                  '• Intelligent Research Tools\n'
                  '• Multi-Skill AI Architecture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 350.ms).fadeIn(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModeGuide(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.4),
                children: [
                  TextSpan(text: "$title → ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: desc, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTag(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B4EE6).withValues(alpha: 0.6), size: 16),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
