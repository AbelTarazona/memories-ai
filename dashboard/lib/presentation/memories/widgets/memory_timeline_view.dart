import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A stunning vertical timeline view for memories grouped by month
class MemoryTimelineView extends StatefulWidget {
  const MemoryTimelineView({
    super.key,
    required this.memories,
  });

  final List<MemoryModel> memories;

  @override
  State<MemoryTimelineView> createState() => _MemoryTimelineViewState();
}

class _MemoryTimelineViewState extends State<MemoryTimelineView>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late ScrollController _scrollController;

  // Gradient colors for the timeline
  static const _gradientStart = Color(0xFF667eea);
  static const _gradientEnd = Color(0xFF764ba2);

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scrollController = ScrollController();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Groups memories by month-year and returns sorted map
  Map<String, List<MemoryModel>> _groupMemoriesByMonth() {
    final grouped = <String, List<MemoryModel>>{};

    for (final memory in widget.memories) {
      // Use normalizedDate if available, otherwise createdAt
      final date = memory.normalizedDate != null
          ? DateTime.tryParse(memory.normalizedDate!) ?? memory.createdAt
          : memory.createdAt;

      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(memory);
    }

    // Sort each group by date descending
    for (final group in grouped.values) {
      group.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  /// Spanish month names
  static const _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  /// Formats month key to human readable format
  String _formatMonthHeader(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;

    final year = int.tryParse(parts[0]) ?? 2024;
    final month = int.tryParse(parts[1]) ?? 1;

    if (month < 1 || month > 12) return key;
    return '${_monthNames[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    final groupedMemories = _groupMemoriesByMonth();
    final sortedKeys = groupedMemories.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    if (sortedKeys.isEmpty) {
      return const Center(
        child: Text('No hay memorias disponibles.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Stack(
              children: [
                // Timeline Line
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_gradientStart, _gradientEnd],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      int monthIndex = 0;
                      monthIndex < sortedKeys.length;
                      monthIndex++
                    ) ...[
                      _MonthHeader(
                        title: _formatMonthHeader(sortedKeys[monthIndex]),
                        entranceController: _entranceController,
                        delay: monthIndex * 0.05,
                      ),
                      const SizedBox(height: 16),
                      ...groupedMemories[sortedKeys[monthIndex]]!
                          .asMap()
                          .entries
                          .map((entry) {
                            final itemIndex = entry.key;
                            final memory = entry.value;
                            final globalDelay =
                                (monthIndex * 0.05) + (itemIndex * 0.08);

                            return _TimelineMemoryCard(
                              memory: memory,
                              entranceController: _entranceController,
                              delay: globalDelay,
                              onTap: () =>
                                  context.push('/memories/${memory.id}'),
                            );
                          }),
                      if (monthIndex < sortedKeys.length - 1)
                        const SizedBox(height: 32),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Glassmorphism month header badge
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.title,
    required this.entranceController,
    required this.delay,
  });

  final String title;
  final AnimationController entranceController;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.5, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: entranceController,
            curve: Interval(
              delay,
              (delay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    final fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: entranceController,
            curve: Interval(
              delay,
              (delay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 52),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea).withValues(alpha: 0.9),
                      const Color(0xFF764ba2).withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive timeline memory card with animations
class _TimelineMemoryCard extends StatefulWidget {
  const _TimelineMemoryCard({
    required this.memory,
    required this.entranceController,
    required this.delay,
    required this.onTap,
  });

  final MemoryModel memory;
  final AnimationController entranceController;
  final double delay;
  final VoidCallback onTap;

  @override
  State<_TimelineMemoryCard> createState() => _TimelineMemoryCardState();
}

class _TimelineMemoryCardState extends State<_TimelineMemoryCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _nodeController;

  @override
  void initState() {
    super.initState();
    _nodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nodeController.dispose();
    super.dispose();
  }

  /// Short Spanish month names
  static const _shortMonthNames = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = _shortMonthNames[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final clampedDelay = widget.delay.clamp(0.0, 0.7);
    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: widget.entranceController,
            curve: Interval(
              clampedDelay,
              (clampedDelay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    final fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: widget.entranceController,
            curve: Interval(
              clampedDelay,
              (clampedDelay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node
              SizedBox(
                width: 52,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _nodeController,
                    builder: (context, child) {
                      final pulseValue = _nodeController.value;
                      return Container(
                        width: 16 + (pulseValue * 4),
                        height: 16 + (pulseValue * 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF667eea,
                              ).withValues(alpha: 0.4 + (pulseValue * 0.2)),
                              blurRadius: 8 + (pulseValue * 8),
                              spreadRadius: pulseValue * 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Card
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(right: _isHovered ? 8 : 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isHovered
                              ? const Color(0xFF667eea).withValues(alpha: 0.5)
                              : AppColors.grey.withValues(alpha: 0.1),
                          width: _isHovered ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered
                                ? const Color(
                                    0xFF667eea,
                                  ).withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: _isHovered ? 24 : 12,
                            offset: Offset(0, _isHovered ? 8 : 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          Hero(
                            tag: 'memory-${widget.memory.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.memory.aiImage ?? '',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    LucideIcons.image,
                                    color: AppColors.grey,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row with badges
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.memory.aiTitle ?? 'Sin título',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.memory.isTruthful)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          LucideIcons.badgeCheck,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Date
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.clock,
                                      size: 14,
                                      color: AppColors.grey.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(widget.memory.createdAt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Feelings emojis
                                if (widget.memory.aiFeelings?.isNotEmpty ??
                                    false)
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: widget.memory.feelingEmojis
                                        .take(5)
                                        .map(
                                          (emoji) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.grey.withValues(
                                                alpha: 0.08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                          // Arrow indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.only(left: _isHovered ? 8 : 0),
                            child: Icon(
                              LucideIcons.chevronRight,
                              color: _isHovered
                                  ? const Color(0xFF667eea)
                                  : AppColors.grey.withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
