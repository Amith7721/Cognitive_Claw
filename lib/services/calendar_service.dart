import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:googleapis/calendar/v3.dart' as cal;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import '../models/calendar_event.dart';
import '../core/theme/app_theme.dart';

class CalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarReadonlyScope, 'email'],
  );

  // LOGIN
  static Future<bool> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();

      debugPrint("Google User: ${user?.email}");

      return user != null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");

      return false;
    }
  }

  // RESTORE LOGIN
  static Future<bool> isSignedIn() async {
    final restoredUser = await _googleSignIn.signInSilently();

    return restoredUser != null;
  }

  // LOGOUT
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // FETCH EVENTS
  static Future<List<CalendarEvent>> getUpcomingEvents({DateTime? date}) async {
    try {
      // RESTORE USER SESSION
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      user ??= await _googleSignIn.signIn();

      if (user == null) {
        debugPrint("No Google user found");
        return [];
      }

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        debugPrint("Authenticated client is null");
        return [];
      }

      final calendarApi = cal.CalendarApi(client);
      
      final start = (date ?? DateTime.now()).copyWith(hour: 0, minute: 0, second: 0).toUtc();
      final end = start.add(const Duration(days: 1)).toUtc();

      final events = await calendarApi.events.list(
        "primary",
        maxResults: 15,
        singleEvents: true,
        orderBy: "startTime",
        timeMin: start,
        timeMax: end,
      );

      final items = events.items ?? [];

      debugPrint("Google Calendar Events Found: ${items.length}");

      for (final event in items) {
        debugPrint("Event: ${event.summary}");
      }

      return items.map((e) {
        return CalendarEvent(
          title: e.summary ?? "No Title",
          startTime: e.start?.dateTime ?? DateTime.now(),
          attendeeNames: e.attendees?.map((a) => a.email ?? "").toList() ?? [],
        );
      }).toList();
    } catch (e) {
      debugPrint("Calendar Fetch Error: $e");

      return [];
    }
  }
}
