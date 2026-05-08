import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/theme/app_theme.dart';

import 'screens/home/home_screen.dart';
import 'screens/briefs/briefs_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/research/research_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/activation_screen.dart';

import 'widgets/cc_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/task_provider.dart';
import 'providers/research_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/vision_provider.dart';
import 'providers/voice_provider.dart';
import 'services/notification_service.dart';
import 'services/cognitive_memory_service.dart';
import 'services/cognitive_dna_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  
  // Open All Persistent Boxes
  await Hive.openBox('tasks');
  await Hive.openBox('settings');
  await Hive.openBox('research_history');
  await Hive.openBox('research_insights');
  await Hive.openBox('vision_insights');
  await Hive.openBox('activity_logs');
  
  // Initialize AI Notification System
  await NotificationService.init();

  // Initialize Persistent Cognitive Memory
  await CognitiveMemoryService.init();
  await CognitiveDNAService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => ResearchProvider()..loadPersistentData()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => VisionProvider()..loadPersistentData()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
      ],
      child: const CognitiveClawApp(),
    ),
  );
}

class CognitiveClawApp extends StatelessWidget {
  const CognitiveClawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Cognitive Claw',
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ActivationScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6B4EE6).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(duration: 2.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B4EE6), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .shimmer(duration: 1500.ms, delay: 800.ms),
                const SizedBox(height: 40),
                const Text(
                  'Cognitive Claw',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),
                const SizedBox(height: 12),
                const Text(
                  'AI Productivity Assistant',
                  style: TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 1.5),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 600.ms),
                const SizedBox(height: 60),
                const CircularProgressIndicator(color: Color(0xFF00F2FE))
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  static final GlobalKey<_MainShellState> navKey = GlobalKey<_MainShellState>();
  
  MainShell() : super(key: navKey);

  static void switchTab(int index) {
    navKey.currentState?._onTabTapped(index);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BriefsScreen(),
    TasksScreen(),
    ResearchScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final voiceProvider = Provider.of<VoiceProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // The Main App Content
          Scaffold(
            body: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: CCBottomNav(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),

          // Global Neural Subtitles
          if (voiceProvider.isSpeaking)
            Positioned(
              bottom: 100, // Above bottom nav
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "USER: ${voiceProvider.userSpeech}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voiceProvider.aiSpeech,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
            ),

          // Absolute Bottom Neural Glow Bar
          if (voiceProvider.isSpeaking)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4EE6).withValues(alpha: 0.8),
                      blurRadius: 35,
                      spreadRadius: 20,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.6),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: Container(color: const Color(0xFF6B4EE6))),
                    Expanded(child: Container(color: const Color(0xFF00F2FE))),
                    Expanded(child: Container(color: const Color(0xFF4E31AA))),
                    Expanded(child: Container(color: const Color(0xFF01C9F7))),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(duration: 1.seconds, color: Colors.white)
               .scaleY(begin: 1.0, end: 3.0, duration: 600.ms, curve: Curves.easeInOut),
            ),
        ],
      ),
    );
  }
}
