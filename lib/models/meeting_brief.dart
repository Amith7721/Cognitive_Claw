class MeetingBrief {
  final String title;
  final String summary;
  final String time;

  MeetingBrief({
    required this.title,
    required this.summary,
    this.time = "Today",
  });
}
