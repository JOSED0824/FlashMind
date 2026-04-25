import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps [FlutterTts] so any widget can call [speak] / [stop] without
/// depending on the underlying plugin directly.
///
/// Language strategy:
///   - 'languages' category → English (en-US) for pronunciation practice.
///   - All other categories  → Spanish (es-MX).
class TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Whether TTS is allowed to speak. Toggled from Settings.
  bool enabled = true;

  /// Current speech rate (0.0–1.0). Default 0.48 ≈ normal pace.
  double speechRate = 0.48;

  bool get isSpeaking => _isSpeaking;

  Future<void> _ensureInit(String lang) async {
    if (!_isInitialized) {
      // setSharedInstance is iOS-only — skip on web and Android
      if (!kIsWeb && Platform.isIOS) {
        await _tts.setSharedInstance(true);
      }
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => _isSpeaking = true);
      _tts.setCompletionHandler(() => _isSpeaking = false);
      _tts.setCancelHandler(() => _isSpeaking = false);
      _isInitialized = true;
    }
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Speaks [text]. Pass [categoryId] so the right language is chosen.
  /// No-op if [enabled] is false.
  Future<void> speak(String text, {String categoryId = ''}) async {
    if (!enabled) return;
    final lang = categoryId == 'languages' ? 'en-US' : 'es-MX';
    await _ensureInit(lang);
    if (_isSpeaking) await _tts.stop();
    await _tts.speak(text);
  }

  /// Stops any ongoing speech immediately.
  Future<void> stop() async {
    if (_isSpeaking) await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
