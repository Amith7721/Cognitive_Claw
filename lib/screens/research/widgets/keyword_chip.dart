import 'package:flutter/material.dart';

class KeywordChip extends StatelessWidget {
  final String keyword;

  const KeywordChip({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.3)),
      ),
      child: Text(
        keyword,
        style: const TextStyle(
          color: Color(0xFF00F2FE),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
