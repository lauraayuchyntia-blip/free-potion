import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    return Container(
      color: const Color(0xFF1A1A2E),
      child: project == null
          ? const Center(child: Text('No project', style: TextStyle(color: AppColors.textMuted)))
          : InteractiveViewer(
              minScale: 0.1,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(100),
              child: Center(
                child: Container(
                  width: project.width.toDouble() * 0.25,
                  height: project.height.toDouble() * 0.25,
                  decoration: BoxDecoration(
                    color: project.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Grid overlay
                      CustomPaint(
                        size: Size(project.width.toDouble() * 0.25, project.height.toDouble() * 0.25),
                        painter: _GridPainter(),
                      ),
                      // Layers
                      ...project.layers
                          .where((l) => l.visible && l.startTime <= provider.currentTime && l.endTime >= provider.currentTime)
                          .map((layer) => _buildLayerWidget(layer, provider)),
                      // Selection overlay
                      if (provider.selectedLayer != null)
                        _SelectionOverlay(layer: provider.selectedLayer!),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLayerWidget(ProjectLayer layer, EditorProvider provider) {
    final canvasW = (provider.currentProject?.width ?? 1080) * 0.25;
    final canvasH = (provider.currentProject?.height ?? 1920) * 0.25;

    Widget content;
    switch (layer.type) {
      case LayerType.text:
        content = Text(
          layer.text ?? 'Text',
          style: TextStyle(
            color: layer.color ?? Colors.white,
            fontSize: (layer.fontSize ?? 24) * 0.25,
            fontFamily: layer.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case LayerType.shape:
        content = Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: layer.color ?? AppColors.accent,
            borderRadius: layer.shapeType == 'circle'
                ? BorderRadius.circular(30)
                : BorderRadius.circular(4),
          ),
        );
        break;
      case LayerType.image:
        content = Container(
          width: 80, height: 80,
          color: AppColors.surfaceElevated,
          child: const Icon(Icons.image, color: AppColors.textMuted),
        );
        break;
      case LayerType.video:
        content = Container(
          width: canvasW, height: canvasH,
          color: Colors.black54,
          child: const Center(child: Icon(Icons.play_circle_outline,
              color: AppColors.textMuted, size: 40)),
        );
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Positioned(
      left: canvasW / 2 + layer.properties.x * 0.25,
      top: canvasH / 2 + layer.properties.y * 0.25,
      child: GestureDetector(
        onTap: () => provider.selectLayer(layer.id),
        child: Transform.rotate(
          angle: layer.properties.rotation * 3.14159 / 180,
          child: Transform.scale(
            scaleX: layer.properties.scaleX,
            scaleY: layer.properties.scaleY,
            child: Opacity(
              opacity: layer.properties.opacity.clamp(0.0, 1.0),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionOverlay extends StatelessWidget {
  final ProjectLayer layer;
  const _SelectionOverlay({required this.layer});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _SelectionPainter()),
      ),
    );
  }
}

class _SelectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 80,
      height: 80,
    );
    canvas.drawRect(rect, paint);

    // Corner handles
    const handleSize = 6.0;
    final handlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    for (final corner in [
      rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight
    ]) {
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Center crosshair
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), centerPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), centerPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
