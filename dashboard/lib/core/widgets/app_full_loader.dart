import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/widgets/text.dart';

class AppFullLoader extends StatefulWidget {
  const AppFullLoader({
    super.key,
    this.centerIcon = const CircularProgressIndicator(),
    this.title,
    this.rotateCenterIcon = false,
  });

  final Widget centerIcon;
  final AppText? title;
  final bool rotateCenterIcon;

  @override
  State<AppFullLoader> createState() => _AppFullLoaderState();
}

class _AppFullLoaderState extends State<AppFullLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = widget.centerIcon;
    if (widget.rotateCenterIcon) {
      icon = RotationTransition(
        turns: _controller,
        child: icon,
      );
    }

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (widget.title != null) ...[
              const SizedBox(height: 16),
              widget.title!,
            ],
          ],
        ),
      ),
    );
  }
}
