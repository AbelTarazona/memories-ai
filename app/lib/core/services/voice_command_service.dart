import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:memories/core/helpers/voice_command_matcher.dart';

/// Servicio singleton para gestionar el reconocimiento de voz para comandos
class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Stream controllers para notificar cambios de estado
  final StreamController<bool> _listeningStateController =
      StreamController<bool>.broadcast();
  final StreamController<String> _recognizedTextController =
      StreamController<String>.broadcast();
  final StreamController<void> _commandDetectedController =
      StreamController<void>.broadcast();

  // Streams públicos
  Stream<bool> get listeningState => _listeningStateController.stream;
  Stream<String> get recognizedText => _recognizedTextController.stream;
  Stream<void> get commandDetected => _commandDetectedController.stream;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio de reconocimiento de voz
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          print('Error en reconocimiento de voz: ${error.errorMsg}');
          _isListening = false;
          _listeningStateController.add(false);
        },
        onStatus: (status) {
          print('Estado de reconocimiento de voz: $status');

          // Cuando se detiene la escucha por timeout, reiniciar automáticamente
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            _listeningStateController.add(false);

            // Re-iniciar automáticamente después de medio segundo
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!_isListening) {
                print('Re-iniciando escucha automáticamente...');
                startListening();
              }
            });
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      print('Error inicializando reconocimiento de voz: $e');
      return false;
    }
  }

  /// Inicia la escucha del comando de voz
  Future<bool> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isListening) {
      print('Ya está escuchando');
      return true;
    }

    try {
      // No usar await porque en web puede devolver null
      _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(
          seconds: 10,
        ), // Escuchar por 10 segundos máximo
        pauseFor: const Duration(
          seconds: 3,
        ), // Pausa después de 3 segundos de silencio
        localeId: 'es-ES', // Español de España
        listenMode: ListenMode.confirmation,
      );

      // Asumir que se inició correctamente
      _isListening = true;
      _listeningStateController.add(true);
      return true;
    } catch (e) {
      print('Error iniciando escucha: $e');
      _isListening = false;
      _listeningStateController.add(false);
      return false;
    }
  }

  /// Detiene la escucha
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      _listeningStateController.add(false);
    } catch (e) {
      print('Error deteniendo escucha: $e');
    }
  }

  /// Callback cuando se recibe un resultado de reconocimiento de voz
  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords;
    print('Texto reconocido: $recognizedWords');

    _recognizedTextController.add(recognizedWords);

    // Verificar si el comando coincide
    if (VoiceCommandMatcher.matchesCommand(recognizedWords)) {
      print(
        '¡Comando detectado! Ratio: ${VoiceCommandMatcher.getBestMatchRatio(recognizedWords)}',
      );
      _commandDetectedController.add(null);

      // Detener temporalmente la escucha
      stopListening();

      // Re-iniciar la escucha después de 3 segundos (después de que se reproduzca el audio y se navegue)
      Future.delayed(const Duration(seconds: 3), () {
        if (!_isListening) {
          startListening();
        }
      });
    } else {
      print(
        'No coincide. Mejor ratio: ${VoiceCommandMatcher.getBestMatchRatio(recognizedWords)}',
      );
    }
  }

  /// Limpia los recursos
  void dispose() {
    _listeningStateController.close();
    _recognizedTextController.close();
    _commandDetectedController.close();
  }
}
