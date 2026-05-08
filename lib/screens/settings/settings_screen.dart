import 'package:flutter/material.dart';
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
    'OpenAI GPT-OSS 20B (Free)': 'openai/gpt-oss-20b:free',
    'OpenAI GPT-OSS 120B (Free)': 'openai/gpt-oss-120b:free',
    'Mistral 7B (Free)': 'mistralai/mistral-7b-instruct:free',
    'Llama 3.3 70B (Free)': 'meta-llama/llama-3.3-70b-instruct:free',
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
            'AI Engine',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Theme.of(context).cardColor,
                value: models.values.contains(settings.selectedModel) ? settings.selectedModel : models.values.first,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B4EE6)),
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                items: models.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.value, child: Text(e.key)),
                    )
                    .toList(),
                onChanged: (v) {
                  settings.setModel(v!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('AI Engine Updated!'),
                      backgroundColor: const Color(0xFF6B4EE6),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    )
                  );
                },
              ),
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, delay: 150.ms).fadeIn(),

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
