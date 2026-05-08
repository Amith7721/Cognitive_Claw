import 'package:flutter/material.dart';


class ChannelTile extends StatelessWidget {
  final String title;

  const ChannelTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(value: true, onChanged: (_) {}, title: Text(title));
  }
}
