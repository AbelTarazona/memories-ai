import 'package:flutter/material.dart';
import 'package:memories/core/helpers/animation_settings.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/header_internals.dart';
import 'package:memories/core/widgets/text.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _homeAnimationEnabled = true;
  bool _detailAnimationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> requestMicrophonePermission() async {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;

      if (mediaDevices == null) {
        print("MediaDevices no soportado en este navegador");
        return;
      }

      // getUserMedia ahora devuelve una JS Promise, usamos .toDart para await
      final stream = await mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart;

      print("Permiso concedido ✅. Stream: $stream");

      // Liberar tracks si no los usarás
      for (var track in stream.getTracks().toDart) {
        track.stop();
      }
    } catch (e) {
      print("Permiso denegado ❌ o error: $e");
    }
  }

  Future<void> _loadPreferences() async {
    final homeEnabled = await AnimationSettings.isHomeAnimationEnabled();
    final detailEnabled =
        await AnimationSettings.isMemoryDetailAnimationEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _homeAnimationEnabled = homeEnabled;
      _detailAnimationEnabled = detailEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeaderInternal(
              title: 'Configuración',
              description: 'Gestiona tus permisos y preferencias',
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _SettingsToggleCard(
                  icon: Icons.home_outlined,
                  title: 'Animación de inicio',
                  description:
                      'Activa una transición dinámica al abrir la pantalla principal.',
                  value: _homeAnimationEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _homeAnimationEnabled = value;
                    });
                    await AnimationSettings.setHomeAnimationEnabled(value);
                  },
                ),
                _SettingsToggleCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Animación de detalle',
                  description:
                      'Muestra efectos sutiles al explorar los recuerdos en detalle.',
                  value: _detailAnimationEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _detailAnimationEnabled = value;
                    });
                    await AnimationSettings
                        .setMemoryDetailAnimationEnabled(value);
                  },
                ),
                _SettingsActionCard(
                  icon: Icons.mic_none_outlined,
                  title: 'Permisos de micrófono',
                  description:
                      'Permite que la aplicación capture notas de voz cuando lo necesites.',
                  actionLabel: 'Solicitar permisos',
                  onPressed: requestMicrophonePermission,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleCard extends StatelessWidget {
  const _SettingsToggleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: icon,
      title: title,
      description: description,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: icon,
      title: title,
      description: description,
      footer: [
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ShadButton.ghost(
            onPressed: onPressed,
            child: AppText(
              text: actionLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;
  final List<Widget>? footer;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, minWidth: 280),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsIcon(icon: icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: title,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        text: description,
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
            if (footer != null) ...footer!,
          ],
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.blueAccent,
        size: 24,
      ),
    );
  }
}
