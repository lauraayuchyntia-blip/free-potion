import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Container(
      height: 42,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Tools
          _ToolBtn(icon: Icons.arrow_selector_tool, tool: 'select',
            current: provider.activeTool, onTap: () => provider.setActiveTool('select'),
            tooltip: 'Select'),
          _ToolBtn(icon: Icons.text_fields, tool: 'text',
            current: provider.activeTool, onTap: () => provider.setActiveTool('text'),
            tooltip: 'Text'),
          _ToolBtn(icon: Icons.crop_square, tool: 'shape',
            current: provider.activeTool, onTap: () => provider.setActiveTool('shape'),
            tooltip: 'Shape'),
          _ToolBtn(icon: Icons.gesture, tool: 'pen',
            current: provider.activeTool, onTap: () => provider.setActiveTool('pen'),
            tooltip: 'Draw'),

          const VerticalDivider(color: AppColors.border, width: 20, indent: 8, endIndent: 8),

          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 16),
            color: AppColors.textSecondary,
            onPressed: () => provider.setZoom(provider.zoom - 0.25),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(provider.zoom * 100).toInt()}%',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11,
                fontVariations: [FontVariation('wght', 500)]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 16),
            color: AppColors.textSecondary,
            onPressed: () => provider.setZoom(provider.zoom + 0.25),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),

          const VerticalDivider(color: AppColors.border, width: 20, indent: 8, endIndent: 8),

          // Aspect ratio indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${provider.currentProject?.width ?? 1080}×${provider.currentProject?.height ?? 1920}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),

          const Spacer(),

          // Effects shortcut
          _QuickBtn(
            icon: Icons.auto_awesome,
            label: 'Effects',
            onTap: () {},
          ),
          const SizedBox(width: 6),
          _QuickBtn(
            icon: Icons.tune,
            label: 'Color',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tool;
  final String current;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolBtn({
    required this.icon,
    required this.tool,
    required this.current,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final active = tool == current;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: active ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: active ? Border.all(color: AppColors.accent.withOpacity(0.5)) : null,
          ),
          child: Icon(icon, size: 16,
            color: active ? AppColors.accent : AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
