import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/presentation/people/bloc/delete_person_bloc.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/presentation/people/insights/person_insights_sheet.dart';
import 'package:memories_web_admin/presentation/people/widgets/register_person_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PersonCard extends StatefulWidget {
  final PeopleModel person;
  final VoidCallback onReload;

  const PersonCard({
    super.key,
    required this.person,
    required this.onReload,
  });

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  final ShadPopoverController _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  String get _assetImage {
    switch (widget.person.gender?.toLowerCase()) {
      case 'male':
        return 'assets/man.png';
      case 'female':
        return 'assets/woman.png';
      case 'nonbinary':
        return 'assets/nonbinary.png';
      default:
        return 'assets/nonbinary.png'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    color: const Color(0xFFF2F4F7), // Light gray background
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(
                      _assetImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            widget.person.genderEmoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Actions Menu
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildActionsMenu(context),
                ),
              ],
            ),
          ),
          // Info Section
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          text: widget.person.displayName,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.person.isSelf) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            text: 'Tú',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: widget.person.alias?.isNotEmpty == true
                        ? widget.person.alias!
                        : (widget.person.gender == 'male'
                              ? 'Amigo'
                              : widget.person.gender == 'female'
                              ? 'Amiga'
                              : 'Conocido'),
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return ShadPopover(
      controller: _popoverController,
      child: ShadButton.ghost(
        child: const Icon(Icons.more_horiz, color: Colors.black54),
        onPressed: _popoverController.toggle,
      ),
      popover: (context) => Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              context,
              icon: LucideIcons.pencil,
              label: 'Editar',
              onTap: () {
                _popoverController.toggle();
                showShadSheet<bool>(
                  context: context,
                  side: ShadSheetSide.right,
                  builder: (sheetContext) {
                    return RegisterPersonSheet(
                      person: widget.person,
                    );
                  },
                ).then((value) {
                  if (value == true) {
                    widget.onReload();
                  }
                });
              },
            ),
            _buildMenuItem(
              context,
              icon: LucideIcons.brainCircuit,
              label: 'Insights',
              onTap: () {
                _popoverController.toggle();
                showShadSheet(
                  context: context,
                  side: ShadSheetSide.right,
                  builder: (sheetContext) {
                    return PersonInsightsSheet(
                      personId: widget.person.id,
                      personName: widget.person.displayName,
                    );
                  },
                );
              },
            ),
            if (!widget.person.isSelf)
              _buildMenuItem(
                context,
                icon: LucideIcons.trash,
                label: 'Eliminar',
                isDestructive: true,
                onTap: () {
                  _popoverController.toggle();
                  _showDeleteDialog(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDestructive ? Colors.red : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDestructive ? Colors.red : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final deletePersonBloc = context.read<DeletePersonBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${widget.person.displayName}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              deletePersonBloc.add(FetchEvent(widget.person.id));
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
