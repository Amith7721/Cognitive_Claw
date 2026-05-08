import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../models/cognitive_dna.dart';
import '../../../services/cognitive_dna_service.dart';
import '../../../providers/settings_provider.dart';

class CognitiveDNACard extends StatefulWidget {
  const CognitiveDNACard({super.key});

  @override
  State<CognitiveDNACard> createState() => _CognitiveDNACardState();
}

class _CognitiveDNACardState extends State<CognitiveDNACard> {
  late CognitiveDNA dna;
  bool _isEvolving = false;

  @override
  void initState() {
    super.initState();
    dna = CognitiveDNAService.getDNA();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: Color(0xFF00F2FE), size: 28),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(duration: 2.seconds, color: Colors.cyanAccent),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cognitive DNA",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "Adaptive Neural Profile",
                      style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${(dna.cognitiveEfficiency * 100).toInt()}%",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                  ),
                  const Text("Efficiency", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Identity Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dna.identityTags.map((tag) => _buildTag(tag)).toList(),
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          // Insights
          ...dna.productivityInsights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFE0979), size: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPulseIndicator("Aura Pulse", dna.auraPulse, Colors.greenAccent),
              
              // NEW PREMIUM BUTTON
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isEvolving ? null : () async {
                    HapticFeedback.mediumImpact();
                    setState(() => _isEvolving = true);
                    final settings = Provider.of<SettingsProvider>(context, listen: false);
                    await CognitiveDNAService.refreshDNA(settings.selectedModel);
                    if (mounted) {
                      setState(() {
                        dna = CognitiveDNAService.getDNA();
                        _isEvolving = false;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isEvolving ? const Color(0xFFFE0979).withValues(alpha: 0.1) : const Color(0xFF00F2FE).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isEvolving ? const Color(0xFFFE0979).withValues(alpha: 0.4) : const Color(0xFF00F2FE).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isEvolving)
                          const Icon(Icons.sync_rounded, color: Color(0xFFFE0979), size: 16)
                              .animate(onPlay: (c) => c.repeat())
                              .rotate(duration: 1.seconds)
                        else
                          const Icon(Icons.sync_rounded, color: Color(0xFF00F2FE), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _isEvolving ? "EVOLVING..." : "EVOLVE DNA",
                          style: TextStyle(
                            color: _isEvolving ? const Color(0xFFFE0979) : const Color(0xFF00F2FE), 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPulseIndicator(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
        const SizedBox(width: 8),
        Text(
          "$label: $value",
          style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
