import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;
    if (project == null) return const SizedBox.shrink();

    final duration = project.duration;
    final zoom = provider.timelineZoom;

    return Column(
      children: [
        // Time ruler
        _TimeRuler(duration: duration, zoom: zoom, currentTime: provider.currentTime,
          onSeek: provider.setCurrentTime),
        // Layer tracks
        Expanded(
          child: project.layers.isEmpty
              ? const Center(
                  child: Text('Add a layer to start editing',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)))
              : ListView.builder(
                  itemCount: project.layers.length,
                  itemBuilder: (context, i) {
                    final layer = project.layers[i];
                    return _LayerTrack(
                      layer: layer,
                      duration: duration,
                      zoom: zoom,
                      currentTime: provider.currentTime,
                      isSelected: layer.id == provider.selectedLayerId,
                      onTap: () => provider.selectLayer(layer.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TimeRuler extends StatelessWidget {
  final double duration;
  final double zoom;
  final double currentTime;
  final ValueChanged<double> onSeek;

  const _TimeRuler({
    required this.duration,
    required this.zoom,
    required this.currentTime,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        final w = context.size?.width ?? 300;
        final t = (d.localPosition.dx / w) * duration;
        onSeek(t.clamp(0, duration));
      },
      onHorizontalDragUpdate: (d) {
        final w = context.size?.width ?? 300;
        final t = (d.localPosition.dx / w) * duration;
        onSeek(t.clamp(0, duration));
      },
      child: Container(
        height: 24,
        color: AppColors.surfaceElevated,
        child: CustomPaint(
          painter: _RulerPainter(
            duration: duration,
            zoom: zoom,
            currentTime: currentTime,
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double duration;
  final double zoom;
  final double currentTime;

  _RulerPainter({required this.duration, required this.zoom, required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()..color = AppColors.textMuted..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final step = size.width / duration;
    for (int i = 0; i <= duration.toInt(); i++) {
      final x = i * step;
      canvas.drawLine(Offset(x, 10), Offset(x, 24), tickPaint);

      if (i % 2 == 0) {
        textPainter.text = TextSpan(
          text: '${i}s',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 2, 2));
      }
    }

    // Playhead
    final playheadX = (currentTime / duration) * size.width;
    final headPaint = Paint()..color = AppColors.accent..strokeWidth = 1.5;
    canvas.drawLine(Offset(playheadX, 0), Offset(playheadX, 24), headPaint);

    final headPath = Path()
      ..moveTo(playheadX - 5, 0)
      ..lineTo(playheadX + 5, 0)
      ..lineTo(playheadX, 6)
      ..close();
    canvas.drawPath(headPath, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.currentTime != currentTime;
}

class _LayerTrack extends StatelessWidget {
  final ProjectLayer layer;
  final double duration;
  final double zoom;
  final double currentTime;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayerTrack({
    required this.layer,
    required this.duration,
    required this.zoom,
    required this.currentTime,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.08) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final startX = (layer.startTime / duration) * w;
          final endX = (layer.endTime / duration) * w;
          final barW = (endX - startX).clamp(4.0, w.toDouble());

          return Stack(
            children: [
              Positioned(
                left: startX,
                top: 4,
                width: barW,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: _layerColor(layer.type).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected
                        ? Border.all(color: AppColors.accent, width: 1)
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(_layerIcon(layer.type), size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(layer.name,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              // Keyframe diamonds
              ...layer.properties.opacityKeyframes.map((kf) {
                final kx = (kf.time / duration) * w;
                return Positioned(
                  left: kx - 4,
                  top: 12,
                  child: Transform.rotate(
                    angle: 0.785,
                    child: Container(
                      width: 8, height: 8,
                      color: AppColors.keyframe,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Color _layerColor(LayerType type) {
    switch (type) {
      case LayerType.video: return const Color(0xFF3B82F6);
      case LayerType.image: return const Color(0xFF10B981);
      case LayerType.text: return const Color(0xFF8B5CF6);
      case LayerType.shape: return const Color(0xFFF59E0B);
      case LayerType.audio: return const Color(0xFFEF4444);
      case LayerType.effect: return const Color(0xFF06B6D4);
    }
  }

  IconData _layerIcon(LayerType type) {
    switch (type) {
      case LayerType.video: return Icons.videocam;
      case LayerType.image: return Icons.image;
      case LayerType.text: return Icons.text_fields;
      case LayerType.shape: return Icons.crop_square;
      case LayerType.audio: return Icons.music_note;
      case LayerType.effect: return Icons.auto_awesome;
    }
  }
}
