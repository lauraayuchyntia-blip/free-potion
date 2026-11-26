import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  Offset _panOffset = Offset.zero;
  double _lastScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  @override
  void dispose() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return const Center(
        child: Text('No project', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return GestureDetector(
      onScaleStart: (d) {
        _lastScale = provider.zoom;
        _lastFocalPoint = d.focalPoint;
      },
      onScaleUpdate: (d) {
        if (d.pointerCount == 2) {
          provider.setZoom((_lastScale * d.scale).clamp(0.1, 5.0));
        } else {
          final delta = d.focalPoint - _lastFocalPoint;
          setState(() => _panOffset += delta);
          _lastFocalPoint = d.focalPoint;
        }
      },
      onTapDown: (d) => _handleTap(context, d, provider, project),
      child: Container(
        color: AppColors.bg,
        child: Center(
          child: Transform.translate(
            offset: _panOffset,
            child: Transform.scale(
              scale: provider.zoom,
              child: _buildCanvas(project, provider),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details,
      EditorProvider provider, Project project) {
    if (provider.activeTool == 'text') {
      provider.addLayer(name: 'Text', type: LayerType.text, text: 'New Text');
      return;
    }
    if (provider.activeTool == 'shape') {
      provider.addLayer(name: 'Shape', type: LayerType.shape, shapeType: 'rectangle');
      return;
    }
    if (provider.activeTool == 'select') {
      provider.selectLayer(null);
    }
  }

  Widget _buildCanvas(Project project, EditorProvider provider) {
    final canvasW = project.width.toDouble();
    final canvasH = project.height.toDouble();
    final screenSize = MediaQuery.of(context).size;
    final scaleX = (screenSize.width * 0.6) / canvasW;
    final scaleY = (screenSize.height * 0.5) / canvasH;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;

    final visibleLayers = project.layers
        .where((l) =>
            l.visible &&
            provider.currentTime >= l.startTime &&
            provider.currentTime <= l.endTime)
        .toList()
        .reversed
        .toList();

    return Container(
      width: canvasW * fitScale,
      height: canvasH * fitScale,
      decoration: BoxDecoration(
        color: project.backgroundColor ?? Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if ((project.backgroundColor?.alpha ?? 255) < 10)
            const _CheckerBoard(),
          if (provider.showGrid)
            const _GridOverlay(),
          ...visibleLayers
              .map((layer) => _buildLayerWidget(layer, fitScale, provider)),
          if (provider.selectedLayer != null)
            _SelectionOverlay(
              layer: provider.selectedLayer!,
              scale: fitScale,
              onMove: (dx, dy) {
                final l = provider.selectedLayer!;
                provider.updateLayerPosition(
                  l.id,
                  l.properties.x + dx / fitScale,
                  l.properties.y + dy / fitScale,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLayerWidget(
      ProjectLayer layer, double scale, EditorProvider provider) {
    final p = layer.properties;
    final w = (layer.width ?? 200) * scale;
    final h = (layer.height ?? 100) * scale;
    final x = p.x * scale;
    final y = p.y * scale;

    Widget content;

    switch (layer.type) {
      case LayerType.text:
        content = Text(
          layer.text ?? '',
          style: TextStyle(
            color: layer.color ?? Colors.white,
            fontSize: (layer.fontSize ?? 48) * scale * p.scaleX,
            fontFamily: layer.fontFamily,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        );

      case LayerType.shape:
        content = _ShapeWidget(
          shapeType: layer.shapeType ?? 'rectangle',
          color: layer.color ?? AppColors.accent,
          width: w,
          height: h,
        );

      case LayerType.image:
        if (layer.filePath != null) {
          content = Image.file(
            File(layer.filePath!),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _PlaceholderLayer(
              icon: Icons.image_outlined,
              label: layer.name,
            ),
          );
        } else {
          content = _PlaceholderLayer(
              icon: Icons.image_outlined, label: layer.name);
        }

      case LayerType.svg:
        if (layer.svgContent != null) {
          content = SvgPicture.string(layer.svgContent!, fit: BoxFit.contain);
        } else if (layer.filePath != null) {
          content = SvgPicture.file(File(layer.filePath!), fit: BoxFit.contain);
        } else {
          content = _PlaceholderLayer(
              icon: Icons.code_outlined, label: layer.name);
        }

      case LayerType.video:
        content = _VideoLayer(
          filePath: layer.filePath,
          controllers: _videoControllers,
          layerId: layer.id,
        );

      case LayerType.audio:
        content = _PlaceholderLayer(
            icon: Icons.music_note_outlined, label: layer.name, subtle: true);

      case LayerType.effect:
        content = _PlaceholderLayer(
            icon: Icons.auto_awesome, label: layer.name, subtle: true);
    }

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: p.opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: p.rotation * math.pi / 180,
          child: Transform.scale(
            scaleX: p.scaleX,
            scaleY: p.scaleY,
            child: GestureDetector(
              onTap: () => provider.selectLayer(layer.id),
              child: SizedBox(width: w, height: h, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shape Widget ─────────────────────────────────────────────────────────────

class _ShapeWidget extends StatelessWidget {
  final String shapeType;
  final Color color;
  final double width;
  final double height;

  const _ShapeWidget({
    required this.shapeType,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ShapePainter(shapeType: shapeType, color: color),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String shapeType;
  final Color color;

  _ShapePainter({required this.shapeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (shapeType) {
      case 'circle':
        canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      case 'triangle':
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, paint);
      case 'star':
        _drawStar(canvas, size, paint);
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(8),
          ),
          paint,
        );
    }
  }

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    const pts = 5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / pts) - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.shapeType != shapeType || old.color != color;
}

// ─── Video Layer ──────────────────────────────────────────────────────────────

class _VideoLayer extends StatefulWidget {
  final String? filePath;
  final Map<String, VideoPlayerController> controllers;
  final String layerId;

  const _VideoLayer(
      {this.filePath,
      required this.controllers,
      required this.layerId});

  @override
  State<_VideoLayer> createState() => _VideoLayerState();
}

class _VideoLayerState extends State<_VideoLayer> {
  VideoPlayerController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.filePath != null) {
      _ctrl = VideoPlayerController.file(File(widget.filePath!))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
      widget.controllers[widget.layerId] = _ctrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) {
      return _PlaceholderLayer(icon: Icons.videocam_outlined, label: 'Video');
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _ctrl!.value.size.width,
        height: _ctrl!.value.size.height,
        child: VideoPlayer(_ctrl!),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }
}

// ─── Placeholder ──────────────────────────────────────────────────────────────

class _PlaceholderLayer extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool subtle;

  const _PlaceholderLayer(
      {required this.icon, required this.label, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    if (subtle) return const SizedBox.expand();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Selection Overlay ────────────────────────────────────────────────────────

class _SelectionOverlay extends StatelessWidget {
  final ProjectLayer layer;
  final double scale;
  final Function(double, double) onMove;

  const _SelectionOverlay(
      {required this.layer, required this.scale, required this.onMove});

  @override
  Widget build(BuildContext context) {
    final p = layer.properties;
    final w = (layer.width ?? 200) * scale;
    final h = (layer.height ?? 100) * scale;
    final x = p.x * scale;
    final y = p.y * scale;

    return Positioned(
      left: x - 2,
      top: y - 2,
      child: GestureDetector(
        onPanUpdate: (d) => onMove(d.delta.dx, d.delta.dy),
        child: Container(
          width: w + 4,
          height: h + 4,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: Stack(
            children: [
              _Handle(left: -4, top: -4),
              _Handle(right: -4, top: -4),
              _Handle(left: -4, bottom: -4),
              _Handle(right: -4, bottom: -4),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final double? left, right, top, bottom;

  const _Handle({this.left, this.right, this.top, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.accent,
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ─── Grid Overlay ─────────────────────────────────────────────────────────────

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Checkerboard ─────────────────────────────────────────────────────────────

class _CheckerBoard extends StatelessWidget {
  const _CheckerBoard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 10.0;
    final paint = Paint();
    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        final isEven =
            ((x / tileSize).toInt() + (y / tileSize).toInt()) % 2 == 0;
        paint.color =
            isEven ? const Color(0xFF303030) : const Color(0xFF1A1A1A);
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
