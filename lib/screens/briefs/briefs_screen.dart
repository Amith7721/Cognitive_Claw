import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../models/meeting_brief.dart';
import '../../services/calendar_service.dart';
import '../../services/meeting_brief_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/ai_loading_widget.dart';
import 'widgets/brief_card.dart';

class BriefsScreen extends StatefulWidget {
  const BriefsScreen({super.key});

  @override
  State<BriefsScreen> createState() => _BriefsScreenState();
}

class _BriefsScreenState extends State<BriefsScreen> {
  bool loading = true;
  bool signedIn = false;
  List<MeetingBrief> briefs = [];
  String errorMessage = "";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadBriefs();
  }

  Future<void> loadBriefs() async {
    setState(() => loading = true);
    try {
      final isSigned = await CalendarService.isSignedIn();

      if (!isSigned) {
        setState(() {
          signedIn = false;
          loading = false;
        });
        return;
      }

      signedIn = true;
      if (mounted) {
        Provider.of<SettingsProvider>(context, listen: false).syncCalendarStatus();
      }
      
      final events = await CalendarService.getUpcomingEvents(date: selectedDate);
      final initial = await MeetingBriefService.getInitialBriefs(events);

      setState(() {
        briefs = initial;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
      debugPrint(e.toString());
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildHorizontalCalendar() {
    final now = DateTime.now();
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 45, 
        controller: ScrollController(initialScrollOffset: 15 * 78.0),
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - 15));
          final isSelected = isSameDay(date, selectedDate);
          final isToday = isSameDay(date, now);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              loadBriefs();
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70,
                  height: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFE0979) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : (isToday ? const Color(0xFF00F2FE) : Colors.grey.withValues(alpha: 0.1)),
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFFFE0979).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TODAY",
                      style: TextStyle(color: Color(0xFF00F2FE), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Meeting Briefs", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (settings.calendarConnected) _buildHorizontalCalendar(),
          Expanded(
            child: loading
                ? AILoadingWidget(modelName: settings.modelName)
                : !settings.calendarConnected
                ? buildLoginRequired(settings).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn()
                : briefs.isEmpty
                ? buildEmptyState().animate().slideY(begin: 0.1, duration: 400.ms).fadeIn()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: briefs.length,
                    itemBuilder: (context, index) {
                      final brief = briefs[index];
                      return BriefCard(brief: brief).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * index)).fadeIn();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginRequired(SettingsProvider settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFE0979).withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFE0979), size: 80),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds),

            const SizedBox(height: 30),

            Text(
              "Connect Google Calendar",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Connect your Google Calendar to generate AI-powered meeting briefs.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: () async {
                setState(() => loading = true);
                final success = await CalendarService.signInWithGoogle();
                if (success) {
                  await settings.syncCalendarStatus();
                  loadBriefs();
                } else {
                  setState(() => loading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sign-in cancelled or failed.'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE0979), Color(0xFF6B4EE6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFE0979).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Connect Google Calendar",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.event_busy_rounded, color: Color(0xFF00F2FE), size: 80),
            ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),

            const SizedBox(height: 30),

            Text(
              "No Meetings",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              errorMessage.isEmpty
                  ? "No events found for ${DateFormat('MMMM dd').format(selectedDate)}."
                  : errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
