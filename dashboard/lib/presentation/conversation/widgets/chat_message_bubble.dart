import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/presentation/conversation/bloc/conversation_bloc.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje principal
            DecoratedBox(
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.blue
                    : AppColors.backgroundContent,
                borderRadius: BorderRadius.circular(18).copyWith(
                  topLeft: Radius.circular(message.isUser ? 18 : 4),
                  topRight: Radius.circular(message.isUser ? 4 : 18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppText(
                  text: message.text ?? '',
                  fontSize: 16,
                  color: message.isUser ? Colors.white : AppColors.black,
                ),
              ),
            ),
            // Memory cards si existen
            if (message.hasMemories) ...[
              const SizedBox(height: 12),
              _MemoryCardsRow(memories: message.relatedMemories!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemoryCardsRow extends StatelessWidget {
  const _MemoryCardsRow({required this.memories});

  final List memories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Memorias relacionadas:',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: memories
              .map((memory) => _MemoryCard(memory: memory))
              .toList(),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory});

  final dynamic memory;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navegar al detalle de la memoria
          context.push('/memories/${memory.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sideBarBackground),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: AppText(
                  text: memory.aiTitle ?? 'Memoria',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
