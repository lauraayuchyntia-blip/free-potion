import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class LayersPanel extends StatelessWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layers = provider.currentProject?.layers ?? [];

    if (layers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_outlined, color: AppColors.textMuted, size: 32),
            SizedBox(height: 8),
            Text('No layers', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: layers.length,
      onReorder: (old, neo) => provider.reorderLayers(old, neo),
      itemBuilder: (context, i) {
        final layer = layers[i];
        final selected = layer.id == provider.selectedLayerId;
        return _LayerItem(
          key: ValueKey(layer.id),
          layer: layer,
          selected: selected,
          onTap: () => provider.selectLayer(layer.id),
          onVisibility: () => provider.toggleLayerVisibility(layer.id),
          onLock: () => provider.toggleLayerLock(layer.id),
          onDelete: () => provider.deleteLayer(layer.id),
          onDuplicate: () => provider.duplicateLayer(layer.id),
        );
      },
    );
  }
}

class _LayerItem extends StatelessWidget {
  final ProjectLayer layer;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onVisibility;
  final VoidCallback onLock;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _LayerItem({
    super.key,
    required this.layer,
    required this.selected,
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
      onLongPress: () => _showMenu(context),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            // Layer type icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _typeColor(layer.type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(_typeIcon(layer.type), size: 14, color: _typeColor(layer.type)),
            ),
            const SizedBox(width: 8),
            // Layer name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    layer.name,
                    style: TextStyle(
                      color: layer.locked
                          ? AppColors.textMuted
                          : (selected ? AppColors.textPrimary : AppColors.textSecondary),
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _layerSubtitle(layer),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            // Visibility toggle
            GestureDetector(
              onTap: onVisibility,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  layer.visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 15,
                  color: layer.visible ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ),
            ),
            // Lock toggle
            GestureDetector(
              onTap: onLock,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  layer.locked ? Icons.lock_outlined : Icons.lock_open_outlined,
                  size: 15,
                  color: layer.locked ? AppColors.warning : AppColors.textMuted,
                ),
              ),
            ),
            // Drag handle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.drag_handle, size: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(layer.name, style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              )),
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.copy_outlined, color: AppColors.textSecondary, size: 18),
              title: const Text('Duplicate', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              onTap: () { onDuplicate(); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(
                layer.visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary, size: 18,
              ),
              title: Text(
                layer.visible ? 'Hide Layer' : 'Show Layer',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              onTap: () { onVisibility(); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(
                layer.locked ? Icons.lock_open_outlined : Icons.lock_outlined,
                color: AppColors.textSecondary, size: 18,
              ),
              title: Text(
                layer.locked ? 'Unlock Layer' : 'Lock Layer',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              onTap: () { onLock(); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
              title: const Text('Delete Layer', style: TextStyle(color: AppColors.danger, fontSize: 14)),
              onTap: () { onDelete(); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(LayerType type) {
    switch (type) {
      case LayerType.video: return Icons.videocam_outlined;
      case LayerType.image: return Icons.image_outlined;
      case LayerType.text: return Icons.text_fields;
      case LayerType.shape: return Icons.crop_square_outlined;
      case LayerType.audio: return Icons.music_note_outlined;
      case LayerType.effect: return Icons.auto_awesome;
      case LayerType.svg: return Icons.code_outlined;
    }
  }

  Color _typeColor(LayerType type) {
    switch (type) {
      case LayerType.video: return const Color(0xFF3B82F6);
      case LayerType.image: return const Color(0xFF10B981);
      case LayerType.text: return const Color(0xFFF59E0B);
      case LayerType.shape: return const Color(0xFF8B5CF6);
      case LayerType.audio: return const Color(0xFFEC4899);
      case LayerType.effect: return const Color(0xFF06B6D4);
      case LayerType.svg: return const Color(0xFFEF4444);
    }
  }

  String _layerSubtitle(ProjectLayer layer) {
    switch (layer.type) {
      case LayerType.text:
        return layer.text?.substring(0, layer.text!.length.clamp(0, 15)) ?? 'Text';
      case LayerType.shape:
        return layer.shapeType ?? 'Shape';
      case LayerType.audio:
      case LayerType.video:
      case LayerType.image:
      case LayerType.svg:
        if (layer.filePath != null) {
          final parts = layer.filePath!.split('/');
          return parts.last;
        }
        return layer.type.name;
      default:
        return '${layer.startTime.toStringAsFixed(1)}s — ${layer.endTime.toStringAsFixed(1)}s';
    }
  }
}
