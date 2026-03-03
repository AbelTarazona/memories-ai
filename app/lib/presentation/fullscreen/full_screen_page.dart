import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/header.dart';
import 'package:memories/core/widgets/header_internals.dart';
import 'package:memories/core/widgets/text.dart';
import 'package:memories/data/models/full_screen_data.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({super.key, required this.data});

  final FullScreenData data;

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: widget.data.hero,
              child: CachedNetworkImage(
                imageUrl: widget.data.memory.aiImage ?? '',
                width: 720,
                height: 720,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 720,
                  height: 720,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 720,
                  height: 720,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF6F9FF),
                  Color(0xFFF6F9FF).withValues(alpha: 0),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: AppHeaderInternal(title: ''),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      AppText(
                        text: widget.data.memory.aiTitle ?? '',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        text: '${widget.data.memory.aiFeelings?.join(', ')}',
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
