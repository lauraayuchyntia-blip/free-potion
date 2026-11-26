import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/layers_panel.dart';
import '../widgets/properties_panel.dart';
import '../widgets/effects_panel.dart';
import '../widgets/keyframes_panel.dart';
import '../widgets/add_layer_sheet.dart';
import '../widgets/export_sheet.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  // Bottom panel: 0=layers, 1=effects, 2=keyframes
  int _bottomTab = 0;
  bool _showBottomPanel = true;
  double _bottomPanelHeight = 220;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text('No project open',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────
            _TopBar(project: project, provider: provider),

            // ── Tool Bar ──────────────────────────────────────────
            _ToolBar(provider: provider),

            // ── Canvas (fills remaining space above timeline) ─────
            Expanded(
              child: Stack(
                children: [
                  const CanvasWidget(),
                  // Collapse/expand timeline button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _showBottomPanel = !_showBottomPanel),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          _showBottomPanel
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Panel (Layers/Effects/KF + Timeline) ───────
            if (_showBottomPanel)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: _bottomPanelHeight,
                child: Column(
                  children: [
                    // Tab bar + controls
                    _BottomTabBar(
                      tab: _bottomTab,
                      onTab: (i) => setState(() => _bottomTab = i),
                      provider: provider,
                      onAddLayer: () => _showAddLayer(context),
                    ),
                    // Tab content
                    Expanded(
                      child: _bottomTab == 0
                          ? const LayersPanel()
                          : _bottomTab == 1
                              ? const EffectsPanel()
                              : const KeyframesPanel(),
                    ),
                  ],
                ),
              ),

            // ── Timeline ──────────────────────────────────────────
            _TimelineSection(provider: provider),
          ],
        ),
      ),

      // Properties bottom sheet when layer selected
      bottomSheet: provider.selectedLayer != null
          ? _PropertiesBottomSheet(provider: provider)
          : null,
    );
  }

  void _showAddLayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddLayerSheet(),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final Project project;
  final EditorProvider provider;

  const _TopBar({required this.project, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textSecondary, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // Project name
          Expanded(
            child: GestureDetector(
              onTap: () => _renameDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined,
                      color: AppColors.textMuted, size: 14),
                ],
              ),
            ),
          ),
          // Undo
          _TopBtn(
            icon: Icons.undo,
            enabled: provider.canUndo,
            onTap: provider.undo,
          ),
          // Redo
          _TopBtn(
            icon: Icons.redo,
            enabled: provider.canRedo,
            onTap: provider.redo,
          ),
          const SizedBox(width: 6),
          // Export
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ExportSheet(),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_download_outlined,
                      color: Colors.white, size: 15),
                  SizedBox(width: 4),
                  Text('Export',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _renameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: project.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Project',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              provider.renameProject(project.id, ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('OK',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _TopBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            color: enabled ? AppColors.textSecondary : AppColors.textMuted,
            size: 20),
      ),
    );
  }
}

// ─── Tool Bar ─────────────────────────────────────────────────────────────────

class _ToolBar extends StatelessWidget {
  final EditorProvider provider;
  const _ToolBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'id': 'select', 'icon': Icons.open_with, 'label': 'Select'},
      {'id': 'text', 'icon': Icons.text_fields, 'label': 'Text'},
      {'id': 'shape', 'icon': Icons.crop_square_outlined, 'label': 'Shape'},
      {'id': 'draw', 'icon': Icons.gesture, 'label': 'Draw'},
      {'id': 'trim', 'icon': Icons.content_cut, 'label': 'Trim'},
    ];

    return Container(
      height: 44,
      color: AppColors.surface,
      child: Row(
        children: [
          // Tool buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: tools.map((t) {
                final active = provider.activeTool == t['id'];
                return GestureDetector(
                  onTap: () =>
                      provider.setActiveTool(t['id'] as String),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Icon(
                      t['icon'] as IconData,
                      color: active
                          ? AppColors.accent
                          : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Divider
          Container(width: 1, height: 24, color: AppColors.border),
          // Zoom info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${(provider.zoom * 100).toInt()}%',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ),
          // Canvas info
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              '${provider.currentProject?.width}×${provider.currentProject?.height}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Tab Bar ───────────────────────────────────────────────────────────

class _BottomTabBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final EditorProvider provider;
  final VoidCallback onAddLayer;

  const _BottomTabBar({
    required this.tab,
    required this.onTab,
    required this.provider,
    required this.onAddLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppColors.surfaceElevated,
      child: Row(
        children: [
          // + Add Layer
          GestureDetector(
            onTap: onAddLayer,
            child: Container(
              width: 44,
              height: 36,
              color: AppColors.accent.withOpacity(0.15),
              child: const Icon(Icons.add,
                  color: AppColors.accent, size: 20),
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          // Tabs
          _Tab(label: 'Layers', index: 0, current: tab, onTap: onTab),
          _Tab(label: 'Effects', index: 1, current: tab, onTap: onTab),
          _Tab(label: 'KF', index: 2, current: tab, onTap: onTab),
          const Spacer(),
          // Layer count badge
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              '${provider.currentProject?.layers.length ?? 0} layers',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _Tab(
      {required this.label,
      required this.index,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 36,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.accent : AppColors.textMuted,
              fontSize: 12,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Timeline Section ─────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  final EditorProvider provider;
  const _TimelineSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        color: AppColors.timeline,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Playback controls
          Container(
            height: 44,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Current time
                _TimeDisplay(provider.currentTime),
                const Spacer(),
                _PlayCtrlBtn(
                  icon: Icons.skip_previous_rounded,
                  onTap: () => provider.setCurrentTime(0),
                ),
                const SizedBox(width: 4),
                // Play/Pause
                GestureDetector(
                  onTap: provider.togglePlay,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _PlayCtrlBtn(
                  icon: Icons.skip_next_rounded,
                  onTap: () => provider.setCurrentTime(
                      provider.currentProject?.duration ?? 10),
                ),
                const Spacer(),
                // Duration + KF toggle
                _TimeDisplay(provider.currentProject?.duration ?? 10,
                    muted: true),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: provider.toggleShowKeyframes,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: provider.showKeyframes
                          ? AppColors.keyframe.withOpacity(0.2)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: provider.showKeyframes
                            ? AppColors.keyframe
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(Icons.diamond_outlined,
                        size: 14,
                        color: provider.showKeyframes
                            ? AppColors.keyframe
                            : AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          // Timeline scroll area
          const Expanded(child: TimelineWidget()),
        ],
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final double time;
  final bool muted;
  const _TimeDisplay(this.time, {this.muted = false});

  @override
  Widget build(BuildContext context) {
    final m = (time ~/ 60).toString().padLeft(2, '0');
    final s = (time % 60).toStringAsFixed(2).padLeft(5, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$m:$s',
        style: TextStyle(
          color: muted ? AppColors.textMuted : AppColors.textSecondary,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _PlayCtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PlayCtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child:
            Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}

// ─── Properties Bottom Sheet ──────────────────────────────────────────────────

class _PropertiesBottomSheet extends StatefulWidget {
  final EditorProvider provider;
  const _PropertiesBottomSheet({required this.provider});

  @override
  State<_PropertiesBottomSheet> createState() =>
      _PropertiesBottomSheetState();
}

class _PropertiesBottomSheetState
    extends State<_PropertiesBottomSheet> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final layer = widget.provider.selectedLayer;
    if (layer == null) return const SizedBox();

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: _expanded ? 320 : 48,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  // Layer type icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _typeColor(layer.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(_typeIcon(layer.type),
                        color: _typeColor(layer.type), size: 13),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      layer.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        widget.provider.selectLayer(null),
                    child: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 16),
                  ),
                ],
              ),
            ),
            // Properties content
            if (_expanded)
              const Expanded(child: PropertiesPanel()),
          ],
        ),
      ),
    );
  }

  Color _typeColor(LayerType t) {
    switch (t) {
      case LayerType.video: return const Color(0xFF3B82F6);
      case LayerType.image: return const Color(0xFF10B981);
      case LayerType.text: return const Color(0xFFF59E0B);
      case LayerType.shape: return const Color(0xFF8B5CF6);
      case LayerType.audio: return const Color(0xFFEC4899);
      case LayerType.effect: return const Color(0xFF06B6D4);
      case LayerType.svg: return const Color(0xFFEF4444);
    }
  }

  IconData _typeIcon(LayerType t) {
    switch (t) {
      case LayerType.video: return Icons.videocam;
      case LayerType.image: return Icons.image;
      case LayerType.text: return Icons.text_fields;
      case LayerType.shape: return Icons.crop_square;
      case LayerType.audio: return Icons.music_note;
      case LayerType.effect: return Icons.auto_awesome;
      case LayerType.svg: return Icons.code;
    }
  }
}
