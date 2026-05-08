import 'package:flutter/material.dart';

class QuietHoursPicker extends StatelessWidget {
  const QuietHoursPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nights_stay_rounded, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 10),
              Text(
                'Quiet Hours',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: '10 PM',
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  items: const [
                    DropdownMenuItem(value: '10 PM', child: Text('10 PM')),
                    DropdownMenuItem(value: '11 PM', child: Text('11 PM')),
                  ],
                  onChanged: (_) {},
                  decoration: InputDecoration(
                    labelText: 'Start',
                    labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: '6 AM',
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  items: const [
                    DropdownMenuItem(value: '6 AM', child: Text('6 AM')),
                    DropdownMenuItem(value: '7 AM', child: Text('7 AM')),
                  ],
                  onChanged: (_) {},
                  decoration: InputDecoration(
                    labelText: 'End',
                    labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
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
}
