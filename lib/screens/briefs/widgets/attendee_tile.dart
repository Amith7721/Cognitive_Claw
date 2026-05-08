import 'package:flutter/material.dart';

class AttendeeTile extends StatelessWidget {
  final String name;

  const AttendeeTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
            child: Text(
              name[0],
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B4EE6), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
