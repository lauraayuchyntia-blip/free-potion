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
      height: 44,
      color: AppColors.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Tool buttons
          _ToolBtn(
            icon: Icons.open_with,
            tool: 'select',
            current: provider.activeTool,
            tooltip: 'Select',
            onTap: () => provider.setActiveTool('select'),
          ),
          _ToolBtn(
            icon: Icons.text_fields,
            tool: 'text',
            current: provider.activeTool,
            tooltip: 'Text',
            onTap: () => provider.setActiveTool('text'),
          ),
          _ToolBtn(
            icon: Icons.crop_square_outlined,
            tool: 'shape',
            current: provider.activeTool,
            tooltip: 'Shape',
            onTap: () => provider.setActiveTool('shape'),
          ),
          _ToolBtn(
            icon: Icons.gesture,
            tool: 'pen',
            current: provider.activeTool,
            tooltip: 'Draw',
            onTap: () => provider.setActiveTool('pen'),
          ),
          _ToolBtn(
            icon: Icons.pan_tool_alt_outlined,
            tool: 'hand',
            current: provider.activeTool,
            tooltip: 'Pan',
            onTap: () => provider.setActiveTool('hand'),
          ),

          _Divider(),

          // Zoom controls
          _IconBtn(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            onTap: () => provider.setZoom(provider.zoom - 0.25),
          ),
          _ZoomLabel(zoom: provider.zoom, onTap: () => provider.setZoom(1.0)),
          _IconBtn(
            icon: Icons.add,
            tooltip: 'Zoom in',
            onTap: () => provider.setZoom(provider.zoom + 0.25),
          ),

          _Divider(),

          // Canvas info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${provider.currentProject?.width ?? 1080}×${provider.currentProject?.height ?? 1920}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),

          const Spacer(),

          // FPS display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(provider.currentProject?.fps ?? 30).toInt()} fps',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
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
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: active ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? AppColors.accent.withOpacity(0.6) : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: active ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ZoomLabel extends StatelessWidget {
  final double zoom;
  final VoidCallback onTap;

  const _ZoomLabel({required this.zoom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            '${(zoom * 100).toInt()}%',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.border,
    );
  }
}
