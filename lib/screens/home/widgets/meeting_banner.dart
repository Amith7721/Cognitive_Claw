import 'package:flutter/material.dart';

class MeetingBanner extends StatelessWidget {
  final String title;
  final String time;
  final int attendees;

  const MeetingBanner({
    super.key,
    required this.title,
    required this.time,
    required this.attendees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFE0979).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE0979).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.video_camera_front_rounded, color: Color(0xFFFE0979)),
              const SizedBox(width: 10),
              Text(
                "Upcoming Meeting",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  time,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 10),
              Text(
                "$attendees attendees",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
