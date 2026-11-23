import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';

class LayersPanel extends StatelessWidget {
  final VoidCallback? onClose;
  const LayersPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layers = provider.currentProject?.layers ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Text('Layers', style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                )),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  color: AppColors.accent,
                  onPressed: () => _showAddMenu(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 16),
                    color: AppColors.textMuted,
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
              ],
            ),
          ),

          // Layer list
          Expanded(
            child: layers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers_outlined, color: AppColors.textMuted, size: 28),
                        SizedBox(height: 8),
                        Text('No layers', style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ))
                : ReorderableListView.builder(
                    onReorder: provider.reorderLayers,
                    itemCount: layers.length,
                    itemBuilder: (context, i) {
                      final layer = layers[i];
                      return _LayerRow(
                        key: ValueKey(layer.id),
                        layer: layer,
                        isSelected: layer.id == provider.selectedLayerId,
                        onTap: () => provider.selectLayer(layer.id),
                        onVisibility: () => provider.toggleLayerVisibility(layer.id),
                        onLock: () => provider.toggleLayerLock(layer.id),
                        onDelete: () => provider.deleteLayer(layer.id),
                        onDuplicate: () => provider.duplicateLayer(layer.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    final provider = context.read<EditorProvider>();
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 60, 0, 0),
      color: AppColors.surfaceElevated,
      items: [
        _menuItem(Icons.videocam_outlined, 'Video', () => provider.addLayer(LayerType.video)),
        _menuItem(Icons.image_outlined, 'Image', () => provider.addLayer(LayerType.image)),
        _menuItem(Icons.text_fields, 'Text', () => provider.addLayer(LayerType.text)),
        _menuItem(Icons.crop_square, 'Shape', () => provider.addLayer(LayerType.shape)),
        _menuItem(Icons.music_note_outlined, 'Audio', () => provider.addLayer(LayerType.audio)),
        _menuItem(Icons.auto_awesome, 'Effect', () => provider.addLayer(LayerType.effect)),
      ],
    );
  }

  PopupMenuItem _menuItem(IconData icon, String label, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final ProjectLayer layer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onVisibility;
  final VoidCallback onLock;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _LayerRow({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onTap,
    required this.onVisibility,
    required this.onLock,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.12)
              : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Type color dot
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: _typeColor(layer.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Icon(_typeIcon(layer.type), size: 14,
              color: isSelected ? AppColors.accent : AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(layer.name, style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ), overflow: TextOverflow.ellipsis),
            ),
            // Visibility
            GestureDetector(
              onTap: onVisibility,
              child: Icon(
                layer.visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 14,
                color: layer.visible ? AppColors.textMuted : AppColors.textMuted.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: 6),
            // Lock
            GestureDetector(
              onTap: onLock,
              child: Icon(
                layer.locked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 14,
                color: layer.locked ? AppColors.warning : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            // Drag handle
            const Icon(Icons.drag_handle, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy_outlined, color: AppColors.textSecondary),
            title: const Text('Duplicate', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () { Navigator.pop(context); onDuplicate(); },
          ),
          ListTile(
            leading: Icon(layer.visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textSecondary),
            title: Text(layer.visible ? 'Hide Layer' : 'Show Layer',
              style: const TextStyle(color: AppColors.textPrimary)),
            onTap: () { Navigator.pop(context); onVisibility(); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.danger),
            title: const Text('Delete Layer', style: TextStyle(color: AppColors.danger)),
            onTap: () { Navigator.pop(context); onDelete(); },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _typeColor(LayerType type) {
    switch (type) {
      case LayerType.video: return const Color(0xFF3B82F6);
      case LayerType.image: return const Color(0xFF10B981);
      case LayerType.text: return const Color(0xFF8B5CF6);
      case LayerType.shape: return const Color(0xFFF59E0B);
      case LayerType.audio: return const Color(0xFFEF4444);
      case LayerType.effect: return const Color(0xFF06B6D4);
    }
  }

  IconData _typeIcon(LayerType type) {
    switch (type) {
      case LayerType.video: return Icons.videocam_outlined;
      case LayerType.image: return Icons.image_outlined;
      case LayerType.text: return Icons.text_fields;
      case LayerType.shape: return Icons.crop_square;
      case LayerType.audio: return Icons.music_note_outlined;
      case LayerType.effect: return Icons.auto_awesome;
    }
  }
}
