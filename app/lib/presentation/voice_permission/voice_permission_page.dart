import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:memories/core/services/voice_command_service.dart';
import 'package:memories/core/services/voice_preferences.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/text.dart';

/// Pantalla de onboarding para solicitar permisos de voz
class VoicePermissionPage extends StatefulWidget {
  const VoicePermissionPage({super.key});

  @override
  State<VoicePermissionPage> createState() => _VoicePermissionPageState();
}

class _VoicePermissionPageState extends State<VoicePermissionPage> {
  final VoiceCommandService _voiceService = VoiceCommandService();
  bool _isRequestingPermission = false;
  String? _errorMessage;

  Future<void> _requestPermission() async {
    setState(() {
      _isRequestingPermission = true;
      _errorMessage = null;
    });

    try {
      // Inicializar el servicio de voz (esto solicita permisos)
      final initialized = await _voiceService.initialize();

      if (initialized) {
        // Guardar que se otorgaron permisos
        await VoicePreferences.setVoicePermission(true);
        await VoicePreferences.setOnboardingCompleted();

        if (mounted) {
          // Navegar al home
          context.go('/');
        }
      } else {
        setState(() {
          _errorMessage = 'No se pudieron obtener permisos de micrófono.';
          _isRequestingPermission = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isRequestingPermission = false;
      });
    }
  }

  void _skipForNow() async {
    // Marcar onboarding como completado pero sin permisos
    await VoicePreferences.setOnboardingCompleted();
    await VoicePreferences.setVoicePermission(false);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/dots.json',
              height: 200,
            ),
            const SizedBox(height: 40),
            AppText(
              text: '¡Hola! 👋',
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            AppText(
              text: 'Activa tu asistente de voz',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  AppText(
                    text: 'Di "Memoris quiero contarte algo"',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 15),
                  AppText(
                    text:
                        'Tu asistente estará siempre listo para escucharte y capturar tus memorias en cualquier momento.',
                    fontSize: 16,
                    textAlign: TextAlign.center,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                ),
                child: AppText(
                  text: _errorMessage!,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _isRequestingPermission ? null : _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isRequestingPermission
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : AppText(
                      text: 'Activar Asistente de Voz',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _isRequestingPermission ? null : _skipForNow,
              child: AppText(
                text: 'Omitir por ahora',
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
