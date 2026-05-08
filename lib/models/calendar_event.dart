class CalendarEvent {
  final String title;
  final DateTime startTime;
  final List<String> attendeeNames;

  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.attendeeNames,
  });
}
