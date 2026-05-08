import 'package:flutter/material.dart';

class ApiKeyTile extends StatelessWidget {
  final String label;

  const ApiKeyTile({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12,
          prefixIcon: Icon(Icons.key_rounded, color: Theme.of(context).iconTheme.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
