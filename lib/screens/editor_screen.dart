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

  bool _showSidePanel = true;
  late AnimationController _sideAnim;
  late Animation<double> _sideSlide;

  @override
  void initState() {
    super.initState();
    _sideAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1,
    );
    _sideSlide = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sideAnim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _sideAnim.dispose();
    super.dispose();
  }

  void _toggleSidePanel() {
    setState(() => _showSidePanel = !_showSidePanel);
    if (_showSidePanel) {
      _sideAnim.forward();
    } else {
      _sideAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text('No project open', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───────────────────────────────────────────
            _TopBar(
              projectName: project.name,
              provider: provider,
              onTogglePanel: _toggleSidePanel,
              showPanel: _showSidePanel,
            ),
            // ─── Toolbar ───────────────────────────────────────────
            const ToolbarWidget(),
            // ─── Main Editor Area ──────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // Side panel (Layers / Effects / Keyframes)
                  AnimatedBuilder(
                    animation: _sideSlide,
                    builder: (_, __) => ClipRect(
                      child: SizedBox(
                        width: 200 * _sideSlide.value,
                        child: const _SidePanel(),
                      ),
                    ),
                  ),
                  // Canvas
                  Expanded(
                    child: Stack(
                      children: [
                        const CanvasWidget(),
                        // Panel toggle button on canvas edge
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _toggleSidePanel,
                              child: Container(
                                width: 16,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8),
                                  ),
                                  border: const Border(
                                    top: BorderSide(color: AppColors.border),
                                    right: BorderSide(color: AppColors.border),
                                    bottom: BorderSide(color: AppColors.border),
                                  ),
                                ),
                                child: Icon(
                                  _showSidePanel
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  color: AppColors.textMuted,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Properties panel (shows when layer selected)
                  if (provider.selectedLayer != null)
                    const SizedBox(
                      width: 240,
                      child: PropertiesPanel(),
                    ),
                ],
              ),
            ),
            // ─── Timeline ──────────────────────────────────────────
            const _TimelineArea(),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar (like Alight Motion header) ─────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String projectName;
  final EditorProvider provider;
  final VoidCallback onTogglePanel;
  final bool showPanel;

  const _TopBar({
    required this.projectName,
    required this.provider,
    required this.onTogglePanel,
    required this.showPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          // Project name (editable)
          Expanded(
            child: GestureDetector(
              onTap: () => _renameDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      projectName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          // Undo
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            color: provider.canUndo ? AppColors.textSecondary : AppColors.textMuted.withOpacity(0.4),
            onPressed: provider.canUndo ? provider.undo : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          // Redo
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            color: provider.canRedo ? AppColors.textSecondary : AppColors.textMuted.withOpacity(0.4),
            onPressed: provider.canRedo ? provider.redo : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
          // Export button
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.surface,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const ExportSheet(),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF9F67FF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Export', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _renameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: projectName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Project', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Project name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              if (provider.currentProject != null) {
                provider.renameProject(provider.currentProject!.id, ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ─── Side Panel (Layers / Effects / Keyframes tabs) ───────────────────────────

class _SidePanel extends StatelessWidget {
  const _SidePanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Tab selector
          Container(
            height: 36,
            color: AppColors.surfaceElevated,
            child: Row(
              children: [
                _SideTab(label: 'Layers', index: 0, current: provider.bottomTab,
                    onTap: () => provider.setBottomTab(0)),
                _SideTab(label: 'Effects', index: 1, current: provider.bottomTab,
                    onTap: () => provider.setBottomTab(1)),
                _SideTab(label: 'KF', index: 2, current: provider.bottomTab,
                    onTap: () => provider.setBottomTab(2)),
              ],
            ),
          ),
          // Panel content
          Expanded(
            child: IndexedStack(
              index: provider.bottomTab,
              children: const [
                LayersPanel(),
                EffectsPanel(),
                KeyframesPanel(),
              ],
            ),
          ),
          // Add layer button
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.surface,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const AddLayerSheet(),
            ),
            child: Container(
              height: 42,
              color: AppColors.surfaceElevated,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.accent, size: 18),
                  SizedBox(width: 6),
                  Text('Add Layer', style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTab extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _SideTab({
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: active ? AppColors.accent : AppColors.textMuted,
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            )),
          ),
        ),
      ),
    );
  }
}

// ─── Timeline Area ────────────────────────────────────────────────────────────

class _TimelineArea extends StatelessWidget {
  const _TimelineArea();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.timeline,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Playback controls bar
          Container(
            height: 40,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Current time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatTime(provider.currentTime),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Spacer(),
                // Skip to start
                _PlayBtn(
                  icon: Icons.skip_previous,
                  onTap: () => provider.setCurrentTime(0),
                ),
                // Play/Pause
                GestureDetector(
                  onTap: provider.togglePlay,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                // Skip to end
                _PlayBtn(
                  icon: Icons.skip_next,
                  onTap: () => provider.setCurrentTime(
                    provider.currentProject?.duration ?? 10,
                  ),
                ),
                const Spacer(),
                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatTime(provider.currentProject?.duration ?? 10),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Keyframe toggle
                GestureDetector(
                  onTap: provider.toggleShowKeyframes,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    child: Icon(
                      Icons.diamond_outlined,
                      size: 14,
                      color: provider.showKeyframes
                          ? AppColors.keyframe
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Timeline
          const Expanded(child: TimelineWidget()),
        ],
      ),
    );
  }

  String _formatTime(double t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toStringAsFixed(2).padLeft(5, '0');
    return '$m:$s';
  }
}

class _PlayBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PlayBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }
}
