import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/layers_panel.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/properties_panel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool _showLayers = true;
  bool _showProperties = true;
  int _bottomTab = 0; // 0=layers, 1=effects, 2=keyframes

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: Text('No project open', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(context, provider, project.name),
      body: Column(
        children: [
          // Toolbar
          const ToolbarWidget(),

          // Main editor area
          Expanded(
            child: Row(
              children: [
                // Layers panel (left)
                if (_showLayers)
                  SizedBox(
                    width: 200,
                    child: LayersPanel(
                      onClose: () => setState(() => _showLayers = false),
                    ),
                  ),

                // Canvas (center)
                Expanded(
                  child: const CanvasWidget(),
                ),

                // Properties panel (right)
                if (_showProperties && provider.selectedLayer != null)
                  SizedBox(
                    width: 220,
                    child: PropertiesPanel(
                      onClose: () => setState(() => _showProperties = false),
                    ),
                  ),
              ],
            ),
          ),

          // Timeline
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: AppColors.timeline,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // Timeline tabs
                Container(
                  height: 36,
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      _TimelineTab(label: 'Layers', index: 0, current: _bottomTab,
                        onTap: () => setState(() => _bottomTab = 0)),
                      _TimelineTab(label: 'Effects', index: 1, current: _bottomTab,
                        onTap: () => setState(() => _bottomTab = 1)),
                      _TimelineTab(label: 'Keyframes', index: 2, current: _bottomTab,
                        onTap: () => setState(() => _bottomTab = 2)),
                      const Spacer(),
                      // Playback controls
                      _PlaybackControls(),
                    ],
                  ),
                ),
                const Expanded(child: TimelineWidget()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !_showLayers
          ? BottomAppBar(
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.layers_outlined),
                    color: AppColors.textSecondary,
                    onPressed: () => setState(() => _showLayers = true),
                    tooltip: 'Show Layers',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.accent,
                    onPressed: () => _showAddLayerSheet(context),
                    tooltip: 'Add Layer',
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined),
                    color: AppColors.textSecondary,
                    onPressed: () => setState(() => _showProperties = !_showProperties),
                    tooltip: 'Properties',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  AppBar _buildAppBar(BuildContext context, EditorProvider provider, String title) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        color: AppColors.textSecondary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      )),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo, size: 20),
          color: AppColors.textSecondary,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.redo, size: 20),
          color: AppColors.textSecondary,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: ElevatedButton.icon(
            onPressed: () => _showExportSheet(context),
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Export', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddLayerSheet(BuildContext context) {
    final provider = context.read<EditorProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Layer', style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            )),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AddLayerButton(icon: Icons.videocam_outlined, label: 'Video',
                  onTap: () { provider.addLayer(LayerType.video); Navigator.pop(ctx); }),
                _AddLayerButton(icon: Icons.image_outlined, label: 'Image',
                  onTap: () { provider.addLayer(LayerType.image); Navigator.pop(ctx); }),
                _AddLayerButton(icon: Icons.text_fields, label: 'Text',
                  onTap: () { provider.addLayer(LayerType.text); Navigator.pop(ctx); }),
                _AddLayerButton(icon: Icons.crop_square, label: 'Shape',
                  onTap: () { provider.addLayer(LayerType.shape); Navigator.pop(ctx); }),
                _AddLayerButton(icon: Icons.music_note_outlined, label: 'Audio',
                  onTap: () { provider.addLayer(LayerType.audio); Navigator.pop(ctx); }),
                _AddLayerButton(icon: Icons.auto_awesome, label: 'Effect',
                  onTap: () { provider.addLayer(LayerType.effect); Navigator.pop(ctx); }),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export', style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            )),
            const SizedBox(height: 16),
            _ExportOption(icon: Icons.videocam, label: 'MP4 Video', sub: '1080p • H.264'),
            _ExportOption(icon: Icons.gif, label: 'GIF Animation', sub: '480p • Optimized'),
            _ExportOption(icon: Icons.image, label: 'PNG Sequence', sub: 'All frames'),
            _ExportOption(icon: Icons.photo, label: 'Still Image', sub: 'Current frame'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;
  const _TimelineTab({required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: active ? AppColors.accent : Colors.transparent,
            width: 2,
          )),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: active ? AppColors.accent : AppColors.textMuted,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          )),
        ),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => provider.setCurrentTime(0),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow, size: 20),
          color: AppColors.accent,
          onPressed: provider.togglePlay,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => provider.setCurrentTime(provider.currentProject?.duration ?? 10),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(provider.currentTime),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _formatTime(double t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toStringAsFixed(2).padLeft(5, '0');
    return '$m:$s';
  }
}

class _AddLayerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddLayerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentGlow, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _ExportOption({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}
