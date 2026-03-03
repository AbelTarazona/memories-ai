/// Se ejecuta cuando se detecta el comando de voz
Future<void> _onCommandDetected() async {
  if (!mounted || _isProcessingCommand) {
    print(
      'Comando ignorado: mounted=$mounted, procesando=$_isProcessingCommand',
    );
    return;
  }

  // Marcar como procesando para evitar duplicados
  _isProcessingCommand = true;
  print('✅ Comando detectado en HomePage, reproduciendo audio...');

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
    // Resetear bandera después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _isProcessingCommand = false;
        print('Bandera de procesamiento reseteada');
      }
    });
  }
}
