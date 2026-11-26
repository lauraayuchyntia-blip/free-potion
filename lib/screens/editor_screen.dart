import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/timeline_widget.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _propTab = 0; // 0=Transform 1=Color 2=Effects 3=Blending

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final provider = context.watch<EditorProvider>();
    final hasLayer = provider.selectedLayer != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: Stack(
                children: [
                  const CanvasWidget(),
                  Positioned(right: 8, top: 8, child: _RightToolbar()),
                  Positioned(left: 12, bottom: 12, child: _ZoomBadge()),
                ],
              ),
            ),
            if (hasLayer) _PropertiesBar(tab: _propTab, onTab: (t) => setState(() => _propTab = t)),
            _TimelineSection(),
          ],
        ),
      ),
    );
  }
}

// ── TOP BAR ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EditorProvider>();
    final proj = p.currentProject;
    return Container(
      height: 48,
      color: AppColors.surface,
      child: Row(
        children: [
          _IBtn(Icons.arrow_back_ios_new, 18, () => Navigator.pop(context)),
          const SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: () => _rename(context, p, proj),
              child: Text(proj?.name ?? 'Free Potion',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          _IBtn(Icons.undo, 20, p.canUndo ? p.undo : null,
              color: p.canUndo ? AppColors.textSecondary : AppColors.textMuted),
          _IBtn(Icons.redo, 20, p.canRedo ? p.redo : null,
              color: p.canRedo ? AppColors.textSecondary : AppColors.textMuted),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _exportSheet(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(6)),
              child: const Text('Export',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _rename(BuildContext ctx, EditorProvider p, Project? proj) {
    if (proj == null) return;
    final ctrl = TextEditingController(text: proj.name);
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Project', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) p.renameProject(proj.id, ctrl.text.trim());
              Navigator.pop(c);
            },
            child: const Text('OK', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _exportSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Export Settings',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _ExRow(Icons.hd, '1080p HD', 'H.264 · 30fps'),
              _ExRow(Icons.four_k, '4K UHD', 'H.264 · 60fps'),
              _ExRow(Icons.gif_box_outlined, 'GIF', '480p · 15fps'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Export Video',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExRow extends StatelessWidget {
  final IconData icon; final String label, sub;
  const _ExRow(this.icon, this.label, this.sub);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, color: AppColors.accent, size: 22),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ]),
      const Spacer(),
      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
    ]),
  );
}

// ── RIGHT TOOLBAR ─────────────────────────────────────────────────────────────

class _RightToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EditorProvider>();
    return Column(children: [
      _TBtn(Icons.near_me, p.activeTool == 'select', () => p.setActiveTool('select')),
      const SizedBox(height: 6),
      _TBtn(Icons.text_fields, p.activeTool == 'text', () => p.setActiveTool('text')),
      const SizedBox(height: 6),
      _TBtn(Icons.crop_square_outlined, p.activeTool == 'shape', () => p.setActiveTool('shape')),
      const SizedBox(height: 6),
      _TBtn(Icons.grid_on, p.showGrid, p.toggleShowGrid),
    ]);
  }
}

class _TBtn extends StatelessWidget {
  final IconData icon; final bool active; final VoidCallback onTap;
  const _TBtn(this.icon, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.accent : AppColors.border),
      ),
      child: Icon(icon, size: 18, color: active ? Colors.white : AppColors.textSecondary),
    ),
  );
}

// ── ZOOM BADGE ────────────────────────────────────────────────────────────────

class _ZoomBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zoom = context.watch<EditorProvider>().zoom;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('${(zoom * 100).round()}%',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    );
  }
}

// ── PROPERTIES BAR ────────────────────────────────────────────────────────────

class _PropertiesBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _PropertiesBar({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EditorProvider>();
    final layer = p.selectedLayer;
    if (layer == null) return const SizedBox.shrink();

    final tabs = ['Transform', 'Color', 'Effects', 'Blending'];

    return Container(
      color: AppColors.surface,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Tab row
        Container(
          height: 40,
          color: const Color(0xFF0F0D1A),
          child: Row(children: [
            ...List.generate(tabs.length, (i) => GestureDetector(
              onTap: () => onTab(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: i == tab ? AppColors.accent : Colors.transparent, width: 2)),
                ),
                child: Text(tabs[i], style: TextStyle(
                  color: i == tab ? AppColors.accent : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: i == tab ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            )),
            const Spacer(),
            GestureDetector(
              onTap: () => p.selectLayer(null),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.close, color: AppColors.textMuted, size: 18),
              ),
            ),
          ]),
        ),

        // Content
        SizedBox(
          height: 100,
          child: IndexedStack(index: tab, children: [
            _TransformContent(layer: layer, p: p),
            _ColorContent(layer: layer, p: p),
            _EffectsContent(layer: layer, p: p),
            _BlendContent(layer: layer),
          ]),
        ),
      ]),
    );
  }
}

class _TransformContent extends StatelessWidget {
  final ProjectLayer layer; final EditorProvider p;
  const _TransformContent({required this.layer, required this.p});
  @override
  Widget build(BuildContext context) {
    final pr = layer.properties;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        _NField('X', pr.x.toStringAsFixed(1),
            (v) { final d = double.tryParse(v); if (d != null) p.updateLayerPosition(layer.id, d, pr.y); }),
        const SizedBox(width: 8),
        _NField('Y', pr.y.toStringAsFixed(1),
            (v) { final d = double.tryParse(v); if (d != null) p.updateLayerPosition(layer.id, pr.x, d); }),
        const SizedBox(width: 8),
        _NField('W', (layer.width ?? 200).toStringAsFixed(0),
            (v) { final d = double.tryParse(v); if (d != null) layer.width = d; }),
        const SizedBox(width: 8),
        _NField('H', (layer.height ?? 100).toStringAsFixed(0),
            (v) { final d = double.tryParse(v); if (d != null) layer.height = d; }),
        const SizedBox(width: 8),
        _NField('Rot°', pr.rotation.toStringAsFixed(1),
            (v) { final d = double.tryParse(v); if (d != null) p.updateLayerRotation(layer.id, d); }),
        const SizedBox(width: 10),
        // Opacity slider
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Opacity', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          SizedBox(
            width: 90,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 2,
                activeTrackColor: AppColors.accent,
                thumbColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(value: pr.opacity, onChanged: (v) => p.updateLayerOpacity(layer.id, v)),
            ),
          ),
        ]),
        const SizedBox(width: 10),
        // Keyframe diamond button
        GestureDetector(
          onTap: () => p.addKeyframe(layer.id, 'position', p.currentTime, {'x': pr.x, 'y': pr.y}),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.keyframe.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.keyframe),
            ),
            child: const Icon(Icons.diamond, color: AppColors.keyframe, size: 16),
          ),
        ),
      ]),
    );
  }
}

class _ColorContent extends StatelessWidget {
  final ProjectLayer layer; final EditorProvider p;
  const _ColorContent({required this.layer, required this.p});
  @override
  Widget build(BuildContext context) {
    final swatches = [
      Colors.red, Colors.deepOrange, Colors.orange, Colors.yellow,
      Colors.green, Colors.teal, Colors.blue, Colors.indigo,
      Colors.purple, Colors.pink, Colors.white, Colors.grey.shade600, Colors.black,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(children: [
        if (layer.color != null) ...[
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: layer.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 10),
        ],
        ...swatches.map((c) => GestureDetector(
          onTap: () => p.updateLayerColor(layer.id, c),
          child: Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: c, shape: BoxShape.circle,
              border: (layer.color?.value == c.value)
                  ? Border.all(color: Colors.white, width: 2) : null,
            ),
          ),
        )),
      ]),
    );
  }
}

class _EffectsContent extends StatelessWidget {
  final ProjectLayer layer; final EditorProvider p;
  const _EffectsContent({required this.layer, required this.p});
  @override
  Widget build(BuildContext context) {
    final fx = ['Blur', 'Glow', 'Shadow', 'Brightness', 'Contrast', 'Saturation', 'Vignette', 'Grain', 'Glitch'];
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: fx.length,
      itemBuilder: (c, i) => GestureDetector(
        onTap: () {
          final e = p.createEffect(fx[i], fx[i].toLowerCase());
          p.addEffect(layer.id, e);
        },
        child: Container(
          width: 68, margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
            const SizedBox(height: 4),
            Text(fx[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

class _BlendContent extends StatelessWidget {
  final ProjectLayer layer;
  const _BlendContent({required this.layer});
  @override
  Widget build(BuildContext context) {
    final modes = ['Normal', 'Multiply', 'Screen', 'Overlay', 'Add', 'Difference', 'Darken', 'Lighten'];
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: modes.length,
      itemBuilder: (c, i) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: i == 0 ? AppColors.accent.withOpacity(0.2) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: i == 0 ? AppColors.accent : AppColors.border),
        ),
        child: Center(child: Text(modes[i], style: TextStyle(
          color: i == 0 ? AppColors.accent : AppColors.textSecondary, fontSize: 12))),
      ),
    );
  }
}

// ── TIMELINE SECTION ──────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EditorProvider>();
    return Container(
      color: AppColors.timeline,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Divider(height: 1, color: AppColors.border),

        // Playback controls
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            // Green + button (Alight Motion style)
            GestureDetector(
              onTap: () => _addLayer(context, p),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 10),

            _PBtn(Icons.skip_previous, 20, () => p.setCurrentTime(0)),
            const SizedBox(width: 2),

            // Play/Pause circle
            GestureDetector(
              onTap: p.togglePlay,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Icon(p.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 2),
            _PBtn(Icons.skip_next, 20, () => p.setCurrentTime(p.currentProject?.duration ?? 10)),
            const SizedBox(width: 10),

            // Time display
            Text(_fmt(p.currentTime),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12,
                    fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            const Text(' / ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text(_fmt(p.currentProject?.duration ?? 10),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'monospace')),

            const Spacer(),

            _PBtn(Icons.zoom_out, 16, () => p.setTimelineZoom(p.timelineZoom - 0.25)),
            _PBtn(Icons.zoom_in, 16, () => p.setTimelineZoom(p.timelineZoom + 0.25)),
            _PBtn(Icons.loop, 18, () {}),
          ]),
        ),

        // Timeline
        const SizedBox(height: 120, child: TimelineWidget()),
      ]),
    );
  }

  String _fmt(double s) {
    final sec = s.floor();
    final cs = ((s - sec) * 100).floor();
    return '${sec.toString().padLeft(2, '0')}:${cs.toString().padLeft(2, '0')}';
  }

  void _addLayer(BuildContext context, EditorProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _AddSheet(p: p),
    );
  }
}

// ── ADD LAYER SHEET ───────────────────────────────────────────────────────────

class _AddSheet extends StatelessWidget {
  final EditorProvider p;
  const _AddSheet({required this.p});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          width: 36, height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            const Text('Add Layer', style: TextStyle(
                color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: AppColors.textMuted),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: [
              _AItem(Icons.videocam_outlined, 'Video', const Color(0xFF3B82F6), () async {
                Navigator.pop(context);
                final r = await FilePicker.platform.pickFiles(type: FileType.video);
                if (r != null && r.files.single.path != null) {
                  p.addLayer(type: LayerType.video, name: r.files.single.name, filePath: r.files.single.path);
                }
              }),
              _AItem(Icons.image_outlined, 'Image', const Color(0xFF10B981), () async {
                Navigator.pop(context);
                final r = await FilePicker.platform.pickFiles(type: FileType.image);
                if (r != null && r.files.single.path != null) {
                  p.addLayer(type: LayerType.image, name: r.files.single.name, filePath: r.files.single.path);
                }
              }),
              _AItem(Icons.text_fields, 'Text', const Color(0xFFF59E0B), () {
                Navigator.pop(context);
                p.addLayer(type: LayerType.text, name: 'Text', text: 'Free Potion');
              }),
              _AItem(Icons.crop_square_outlined, 'Shape', const Color(0xFF8B5CF6), () {
                Navigator.pop(context);
                _shapePicker(context, p);
              }),
              _AItem(Icons.music_note_outlined, 'Audio', const Color(0xFFEC4899), () async {
                Navigator.pop(context);
                final r = await FilePicker.platform.pickFiles(type: FileType.audio);
                if (r != null && r.files.single.path != null) {
                  p.addLayer(type: LayerType.audio, name: r.files.single.name, filePath: r.files.single.path);
                }
              }),
              _AItem(Icons.auto_awesome, 'Effect', const Color(0xFF06B6D4), () {
                Navigator.pop(context);
                p.addLayer(type: LayerType.effect, name: 'Effect');
              }),
              _AItem(Icons.code_outlined, 'SVG', const Color(0xFFEF4444), () async {
                Navigator.pop(context);
                final r = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['svg']);
                if (r != null && r.files.single.path != null) {
                  p.addLayer(type: LayerType.svg, name: r.files.single.name, filePath: r.files.single.path);
                }
              }),
              _AItem(Icons.draw_outlined, 'Draw', const Color(0xFFFF6B6B), () {
                Navigator.pop(context);
                p.addLayer(type: LayerType.shape, name: 'Drawing', shapeType: 'freehand');
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  void _shapePicker(BuildContext ctx, EditorProvider prov) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose Shape', style: TextStyle(
              color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: ['rectangle', 'circle', 'triangle', 'star', 'gradient'].map((s) =>
              GestureDetector(
                onTap: () {
                  Navigator.pop(c);
                  prov.addLayer(type: LayerType.shape, name: _cap(s), shapeType: s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(_cap(s), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
              )
            ).toList(),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _AItem extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _AItem(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

class _IBtn extends StatelessWidget {
  final IconData icon; final double size; final VoidCallback? onTap; final Color? color;
  const _IBtn(this.icon, this.size, this.onTap, {this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Icon(icon, size: size, color: color ?? AppColors.textSecondary),
    ),
  );
}

class _PBtn extends StatelessWidget {
  final IconData icon; final double size; final VoidCallback? onTap;
  const _PBtn(this.icon, this.size, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Icon(icon, size: size, color: AppColors.textSecondary),
    ),
  );
}

class _NField extends StatelessWidget {
  final String label, value; final ValueChanged<String> onChanged;
  const _NField(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      const SizedBox(height: 2),
      SizedBox(
        width: 58, height: 32,
        child: TextField(
          controller: TextEditingController(text: value),
          onSubmitted: onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.accent)),
          ),
        ),
      ),
    ],
  );
}
