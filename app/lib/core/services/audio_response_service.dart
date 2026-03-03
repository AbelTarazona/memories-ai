import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Servicio para reproducir respuestas de audio
class AudioResponseService {
  static final AudioResponseService _instance =
      AudioResponseService._internal();
  factory AudioResponseService() => _instance;
  AudioResponseService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Reproduce el audio de bienvenida y retorna un Future que se completa cuando termina
  Future<void> playWelcomeAudio() async {
    try {
      _isPlaying = true;

      // Configurar el audio player
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setPlaybackRate(1.0);

      // Reproducir el audio desde assets
      await _audioPlayer.play(AssetSource('audios/hola_abel.mp3'));

      // Esperar a que termine el audio
      final completer = Completer<void>();

      StreamSubscription? subscription;
      subscription = _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        subscription?.cancel();
        completer.complete();
      });

      // También escuchar errores
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          _isPlaying = false;
        }
      });

      return completer.future;
    } catch (e) {
      _isPlaying = false;
      print('Error reproduciendo audio de bienvenida: $e');
      // No lanzar excepción, solo completar para que continúe el flujo
      return Future.value();
    }
  }

  /// Detiene la reproducción del audio si está sonando
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error deteniendo audio: $e');
    }
  }

  /// Libera los recursos del audio player
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
    } catch (e) {
      print('Error liberando recursos de audio: $e');
    }
  }
}
