import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) return const SizedBox();

    final duration = project.duration;
    final layers = project.layers;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final totalW = constraints.maxW > 0 ? constraints.maxW : 600.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            child: Column(
              children: [
                // Time ruler
                _TimeRuler(
                  duration: duration,
                  width: totalW,
                  currentTime: provider.currentTime,
                  onSeek: (t) => provider.setCurrentTime(t),
                ),
                // Layer tracks
                Expanded(
                  child: Stack(
                    children: [
                      // Track backgrounds
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: layers.length,
                        itemBuilder: (ctx, i) => _TrackBackground(
                          layer: layers[i],
                          selected: layers[i].id == provider.selectedLayerId,
                          width: totalW,
                          duration: duration,
                          onTap: () => provider.selectLayer(layers[i].id),
                          onLayerTap: (t) => _handleLayerTap(context, layers[i], t, provider, totalW, duration),
                        ),
                      ),
                      // Playhead
                      _Playhead(
                        time: provider.currentTime,
                        duration: duration,
                        totalWidth: totalW,
                        height: layers.length * 36.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLayerTap(BuildContext context, ProjectLayer layer, double tapX, EditorProvider provider, double totalW, double duration) {
    final t = tapX / totalW * duration;
    provider.setCurrentTime(t);
    provider.selectLayer(layer.id);
  }
}

// ─── Time Ruler ───────────────────────────────────────────────────────────────

class _TimeRuler extends StatelessWidget {
  final double duration;
  final double width;
  final double currentTime;
  final ValueChanged<double> onSeek;

  const _TimeRuler({
    required this.duration,
    required this.width,
    required this.currentTime,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => onSeek(d.localPosition.dx / width * duration),
      onHorizontalDragUpdate: (d) => onSeek(
        (d.localPosition.dx / width * duration).clamp(0, duration),
      ),
      child: Container(
        height: 24,
        color: AppColors.surfaceElevated,
        child: CustomPaint(
          painter: _RulerPainter(duration: duration, width: width, currentTime: currentTime),
          size: Size(width, 24),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double duration;
  final double width;
  final double currentTime;

  _RulerPainter({required this.duration, required this.width, required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.5)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 9,
      fontFamily: 'monospace',
    );

    // Draw ticks every 1 second (or fraction)
    final tickInterval = duration > 60 ? 5.0 : duration > 20 ? 2.0 : 1.0;
    for (double t = 0; t <= duration; t += tickInterval) {
      final x = t / duration * width;
      final major = t % (tickInterval * 5) == 0 || t == 0;
      final tickH = major ? 12.0 : 6.0;
      canvas.drawLine(Offset(x, size.height - tickH), Offset(x, size.height), tickPaint);

      if (major) {
        final label = _formatTime(t);
        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 2, 2));
      }
    }

    // Current time marker on ruler
    final cx = currentTime / duration * width;
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height),
      Paint()..color = AppColors.playhead..strokeWidth = 1.5,
    );
  }

  String _formatTime(double t) {
    final m = t ~/ 60;
    final s = (t % 60).toStringAsFixed(0).padLeft(2, '0');
    return m > 0 ? '$m:$s' : '${s}s';
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) =>
      old.currentTime != currentTime || old.duration != duration;
}

// ─── Track Background ─────────────────────────────────────────────────────────

class _TrackBackground extends StatelessWidget {
  final ProjectLayer layer;
  final bool selected;
  final double width;
  final double duration;
  final VoidCallback onTap;
  final ValueChanged<double> onLayerTap;

  const _TrackBackground({
    required this.layer,
    required this.selected,
    required this.width,
    required this.duration,
    required this.onTap,
    required this.onLayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final startX = layer.startTime / duration * width;
    final endX = layer.endTime / duration * width;
    final barW = endX - startX;

    return GestureDetector(
      onTap: onTap,
      onTapDown: (d) => onLayerTap(d.localPosition.dx),
      child: Container(
        height: 36,
        color: selected
            ? AppColors.accent.withOpacity(0.06)
            : AppColors.timeline,
        child: Stack(
          children: [
            // Track bar
            Positioned(
              left: startX,
              top: 4,
              child: GestureDetector(
                onHorizontalDragUpdate: (d) {
                  // drag bar to reposition (handled in provider)
                },
                child: Container(
                  width: barW.clamp(8.0, double.infinity),
                  height: 28,
                  decoration: BoxDecoration(
                    color: _trackColor(layer.type).withOpacity(selected ? 0.6 : 0.35),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _trackColor(layer.type).withOpacity(selected ? 0.9 : 0.5),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(_layerIcon(layer.type), size: 10, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          layer.name,
                          style: const TextStyle(color: Colors.white, fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Keyframe diamonds
                      ...layer.keyframes.map((kf) {
                        final kx = (kf.time - layer.startTime) / (layer.endTime - layer.startTime);
                        if (kx < 0 || kx > 1) return const SizedBox();
                        return Icon(Icons.diamond, size: 6, color: AppColors.keyframe);
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // Track divider
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: Divider(color: AppColors.border, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  Color _trackColor(LayerType type) {
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

  IconData _layerIcon(LayerType type) {
    switch (type) {
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

// ─── Playhead ─────────────────────────────────────────────────────────────────

class _Playhead extends StatelessWidget {
  final double time;
  final double duration;
  final double totalWidth;
  final double height;

  const _Playhead({
    required this.time,
    required this.duration,
    required this.totalWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final rawX = duration > 0 ? time / duration * totalWidth : 0.0;
    // Clamp agar tidak keluar bounds timeline
    final x = rawX.clamp(0.0, totalWidth - 2);

    return Positioned(
      left: x,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          width: 2,
          decoration: BoxDecoration(
            color: AppColors.playhead,
            boxShadow: [
              BoxShadow(
                color: AppColors.playhead.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on BoxConstraints {
  double get maxW => maxWidth.isFinite ? maxWidth : 600;
}
