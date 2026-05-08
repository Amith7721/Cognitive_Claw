import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  bool _activating = false;

  Future<void> _handleActivation() async {
    setState(() => _activating = true);

    try {
      // Request all necessary permissions
      final permissions = [
        Permission.microphone,
        Permission.camera,
        Permission.notification,
        Permission.photos, // Better for modern Android than generic storage
      ];
      
      for (var p in permissions) {
        await p.request();
      }

      // Even if some are denied, we proceed for the demo
      debugPrint("Activation sequence complete.");

      if (mounted) {
        // Navigate to MainShell
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainShell(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    } catch (e) {
      debugPrint("Activation Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Activation Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          // Background Aura
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF6B4EE6).withValues(alpha: 0.15),
                    const Color(0xFF0F111A),
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.power_settings_new_rounded, color: Color(0xFF6B4EE6), size: 40),
                ).animate().scale(duration: 600.ms).fadeIn(),
                
                const SizedBox(height: 40),
                
                const Text(
                  "SYSTEM ACTIVATION",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 12),
                
                Text(
                  "Initialize Cognitive Claw Neural Engine",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 80),
                
                // The "ON" Button
                GestureDetector(
                  onTap: _activating ? null : _handleActivation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _activating ? const Color(0xFF00F2FE).withValues(alpha: 0.6) : const Color(0xFF6B4EE6).withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: _activating 
                          ? [const Color(0xFF00F2FE), const Color(0xFF6B4EE6)] 
                          : [const Color(0xFF6B4EE6), const Color(0xFF00F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: _activating 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "ON",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
                  
                const SizedBox(height: 40),
                
                const Text(
                  "STARTING ENGINE",
                  style: TextStyle(
                    color: Color(0xFF00F2FE),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
