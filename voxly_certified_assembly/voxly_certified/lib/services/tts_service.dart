import 'package:flutter_tts/flutter_tts.dart';
import '../models/task_model.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45); // Slightly slower for a more natural feel
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Hey,";
  }

  Future<void> greetAndReadTasks({
    required String name,
    required List<Task> pendingTasks,
    bool isQuietHours = false,
  }) async {
    if (isQuietHours) return;

    final int count = pendingTasks.length;
    final String greeting = _timeBasedGreeting();

    String script = "$greeting $name. ";
    if (count == 0) {
      script += "All your tasks are done! You're crushing it today.";
    } else if (count == 1) {
      script += "You have 1 task today. ${pendingTasks[0].title}.";
    } else {
      script += "You have $count tasks today. ";
      for (int i = 0; i < pendingTasks.length; i++) {
        final t = pendingTasks[i];
        final timeStr = t.time != null ? "at ${t.time}" : "";
        script += "${t.title} $timeStr. ";
      }
    }

    await speak(script);
  }
}
