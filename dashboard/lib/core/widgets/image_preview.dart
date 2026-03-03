import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    this.width = 250,
    this.height = 220,
    this.imagePath = 'assets/images/example.jpg',
    this.onTap,
    required this.heroTag,
    required this.title,
    required this.description,
  });

  final double width;
  final double height;
  final String imagePath;
  final VoidCallback? onTap;
  final String heroTag;
  final String title;
  final String description;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: widget.width,
              height: widget.height,
              color: AppColors.grey.withValues(alpha: .1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: widget.width,
              height: widget.height,
              color: AppColors.grey.withValues(alpha: .1),
              child: const Center(
                child: Icon(Icons.error, size: 40, color: AppColors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
