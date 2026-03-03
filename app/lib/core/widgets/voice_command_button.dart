import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/core/services/audio_response_service.dart';
import 'package:memories/core/services/voice_command_service.dart';

/// Widget de botón flotante para activar el comando de voz
class VoiceCommandButton extends StatefulWidget {
  const VoiceCommandButton({super.key});

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  final VoiceCommandService _voiceService = VoiceCommandService();
  final AudioResponseService _audioService = AudioResponseService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _isProcessing = false;
  StreamSubscription? _listeningSubscription;
  StreamSubscription? _commandDetectedSubscription;

  @override
  void initState() {
    super.initState();

    // Configurar animación de pulso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Escuchar cambios en el estado de escucha
    _listeningSubscription = _voiceService.listeningState.listen((isListening) {
      if (mounted) {
        setState(() {
          _isListening = isListening;
        });

        if (isListening) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.stop();
          _animationController.reset();
        }
      }
    });

    // Escuchar cuando se detecta el comando
    _commandDetectedSubscription = _voiceService.commandDetected.listen((_) {
      _onCommandDetected();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listeningSubscription?.cancel();
    _commandDetectedSubscription?.cancel();
    super.dispose();
  }

  /// Se llama cuando se detecta el comando de voz
  Future<void> _onCommandDetected() async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Reproducir el audio de bienvenida
      await _audioService.playWelcomeAudio();

      // Navegar a la página de grabación después del audio
      if (mounted) {
        context.push('/record-memory', extra: {'autoStart': true});
      }
    } catch (e) {
      print('Error procesando comando: $e');
      // Si hay error, navegar de todas formas
      if (mounted) {
        context.push('/record-memory', extra: {'autoStart': true});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Alterna el estado de escucha
  Future<void> _toggleListening() async {
    if (_isProcessing) return;

    if (_isListening) {
      await _voiceService.stopListening();
    } else {
      final started = await _voiceService.startListening();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo iniciar el reconocimiento de voz. Verifica los permisos del micrófono.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _isListening
                    ? Colors.red.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
                blurRadius: _isListening ? 20 : 10,
                spreadRadius: _isListening ? 5 : 2,
              ),
            ],
          ),
          child: Material(
            color: _isProcessing
                ? Colors.green
                : _isListening
                ? Colors.red
                : Colors.blue,
            shape: const CircleBorder(),
            elevation: 8,
            child: InkWell(
              onTap: _toggleListening,
              customBorder: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(15),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
