import 'dart:async';

import 'package:flutter/material.dart';

class TopToast {
  TopToast._();

  // Mantiene un único toast por ancla
  static final Map<GlobalKey, OverlayEntry> _entries = {};
  static final Map<GlobalKey, Timer> _timers = {};

  /// Muestra un toast anclado al rectángulo global de [anchorKey].
  static void showAnchored(
    BuildContext context, {
    required GlobalKey anchorKey,
    required String message,
    Duration showFor = const Duration(seconds: 3),
    EdgeInsets innerMargin = const EdgeInsets.only(
      top: 12,
      left: 16,
      right: 16,
    ),
  }) {
    // Si ya hay uno en ese ancla, no duplicar
    if (_entries.containsKey(anchorKey)) return;

    final rect = _rectFor(anchorKey);
    if (rect == null) {
      // Si aún no hay layout, reintenta en el próximo frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAnchored(
          context,
          anchorKey: anchorKey,
          message: message,
          showFor: showFor,
          innerMargin: innerMargin,
        );
      });
      return;
    }

    final entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: rect.top + innerMargin.top,
          left: rect.left + innerMargin.left,
          width: rect.width - innerMargin.left - innerMargin.right,
          child: _ToastCard(message: message),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(entry);
    _entries[anchorKey] = entry;

    // Programar ocultado
    _timers[anchorKey]?.cancel();
    _timers[anchorKey] = Timer(showFor, () => hideAnchored(anchorKey));
  }

  /// Oculta el toast anclado a [anchorKey] (si existe).
  static void hideAnchored(GlobalKey anchorKey) {
    // Cancela el timer si sigue activo
    _timers.remove(anchorKey)?.cancel();

    final entry = _entries.remove(anchorKey);
    entry?.remove();
  }

  static Rect? _rectFor(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      box.size.width,
      box.size.height,
    );
    // Nota: si el contenedor cambia de tamaño mientras el toast está visible,
    // podrías recomputar el rect y llamar entry.markNeedsBuild() si guardas el rect en State.
  }
}

/// Tarjeta del toast con animaciones implícitas (fade + slide).
class _ToastCard extends StatefulWidget {
  const _ToastCard({required this.message});

  final String message;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> {
  double _opacity = 0;
  double _dy = -8; // px hacia arriba (slide-in)

  @override
  void initState() {
    super.initState();
    // Lanzar animación de entrada
    Future.microtask(() {
      setState(() {
        _opacity = 1;
        _dy = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _dy, end: _dy),
      duration: const Duration(milliseconds: 220),
      builder: (context, value, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _opacity,
          child: Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.message,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}
