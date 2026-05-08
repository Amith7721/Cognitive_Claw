import 'dart:async';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  static final FlutterTts _tts = FlutterTts();
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;

  static bool get isSpeaking => _isSpeaking;

  static Future<void> speak(String text) async {
    final completer = Completer<void>();
    
    try {
      _isSpeaking = true;
      
      // Reset to defaults then apply human-like profile
      await _tts.setLanguage("en-US");
      
      // HUMAN PROFILING:
      // Humans don't speak at a perfectly flat 1.0 pitch. 
      // 0.85 - 0.95 range is perceived as "warmer" and more "human-organic".
      await _tts.setPitch(0.92); 
      
      // Standard robotic rate is 0.5. 
      // 0.42 - 0.46 creates a "thoughtful agent" cadence.
      await _tts.setSpeechRate(0.44); 
      await _tts.setVolume(1.0);

      if (Platform.isAndroid) {
        // Force the Google Engine for highest fidelity neural models
        await _tts.setEngine("com.google.android.tts");
      }

      // HIGH FIDELITY VOICE SCANNING
      try {
        final voices = await _tts.getVoices;
        bool voiceFound = false;
        
        // Priority list for "Real Human" sounding models
        final priorityMarkers = ["studio", "enhanced", "neural", "premium", "network"];
        
        for (var marker in priorityMarkers) {
          for (var voice in voices) {
            if (voice is Map) {
              final String name = voice['name']?.toString().toLowerCase() ?? "";
              final String locale = voice['locale']?.toString().toLowerCase() ?? "";
              
              if (locale.contains("en-us") && name.contains(marker)) {
                await _tts.setVoice({"name": voice['name'], "locale": voice['locale']});
                debugPrint("Neural Engine engaged: $name");
                voiceFound = true;
                break;
              }
            }
          }
          if (voiceFound) break;
        }
        
        // Fallback to a high-quality localized voice if no markers found
        if (!voiceFound) {
          await _tts.setVoice({"name": "en-us-x-sfg-local", "locale": "en-US"});
        }
      } catch (e) {
        debugPrint("Voice scanning error: $e");
      }

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        if (!completer.isCompleted) completer.complete();
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        if (!completer.isCompleted) completer.complete();
      });

      // Tiny natural pause before speaking to simulate "AI Processing" time
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _tts.speak(text);
      
      // Wait for actual completion
      await completer.future;
    } catch (e) {
      debugPrint("TTS Error: $e");
      _isSpeaking = false;
    }
  }

  static Future<bool> _initSpeech() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint("Speech Status: $status"),
        onError: (error) => debugPrint("Speech Error: $error"),
        debugLogging: true,
      );
      return _isInitialized;
    } catch (e) {
      debugPrint("Speech Init Error: $e");
      return false;
    }
  }

  static Future<String> listen() async {
    final completer = Completer<String>();
    
    try {
      bool available = await _initSpeech();

      if (!available) {
        debugPrint("Speech recognition not available");
        return "";
      }

      if (!(await _speech.hasPermission)) {
        _isInitialized = await _speech.initialize();
        if (!_isInitialized) return "";
      }

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            if (!completer.isCompleted) completer.complete(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );

      Future.delayed(const Duration(seconds: 11), () {
        if (!completer.isCompleted) completer.complete("");
      });

      final result = await completer.future;
      await _speech.stop();
      return result;
    } catch (e) {
      debugPrint("STT Error: $e");
      return "";
    }
  }
}
