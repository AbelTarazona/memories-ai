import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.items,
    this.distance = 112.0,
    this.children = const [],
  });

  final List<ExpandableFabItem> items;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildExpandingActionButtons(),
        FloatingActionButton(
          backgroundColor: AppColors.blue,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _expandAnimation.value * math.pi / 4,
                child: Icon(
                  _open ? LucideIcons.plus : LucideIcons.menu,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.items.length;
    for (var i = 0; i < count; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 90,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.items[i],
        ),
      );
    }
    return children;
  }
}

class ExpandableFabItem extends StatelessWidget {
  const ExpandableFabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          backgroundColor: Colors.white,
          onPressed: onPressed,
          child: Icon(icon, color: AppColors.blue),
        ),
      ],
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.maxDistance,
    required this.progress,
    required this.child,
    required this.directionInDegrees,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final double directionInDegrees;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: FadeTransition(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
