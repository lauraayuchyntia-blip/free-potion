import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class KeyframesPanel extends StatelessWidget {
  const KeyframesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layer = provider.selectedLayer;

    if (layer == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond_outlined, color: AppColors.textMuted, size: 32),
            SizedBox(height: 8),
            Text('Select a layer', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            SizedBox(height: 4),
            Text('to view keyframes', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      );
    }

    final keyframes = layer.keyframes;

    return Column(
      children: [
        // Header with add button
        Container(
          height: 36,
          color: AppColors.surfaceElevated,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Icon(Icons.diamond_outlined, size: 14, color: AppColors.keyframe),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${layer.name} — ${keyframes.length} keyframe${keyframes.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => provider.addKeyframe(
                  layer.id,
                  'position',
                  provider.currentTime,
                  {'x': layer.properties.x, 'y': layer.properties.y},
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.keyframe, size: 14),
                    SizedBox(width: 2),
                    Text('Add KF', style: TextStyle(
                      color: AppColors.keyframe, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Keyframe list
        Expanded(
          child: keyframes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.keyframe.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.diamond_outlined,
                            color: AppColors.keyframe, size: 24),
                      ),
                      const SizedBox(height: 10),
                      const Text('No keyframes yet', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('Tap "Add KF" to create one\nat the current time',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: keyframes.length,
                  itemBuilder: (ctx, i) => _KeyframeItem(
                    kf: keyframes[i],
                    isActive: (keyframes[i].time - provider.currentTime).abs() < 0.05,
                    onJump: () => provider.setCurrentTime(keyframes[i].time),
                  ),
                ),
        ),

        // Properties being animated
        if (keyframes.isNotEmpty) ...[
          const Divider(color: AppColors.border, height: 1),
          _AnimatedPropertiesList(keyframes: keyframes),
        ],
      ],
    );
  }
}

class _KeyframeItem extends StatelessWidget {
  final Keyframe kf;
  final bool isActive;
  final VoidCallback onJump;

  const _KeyframeItem({required this.kf, required this.isActive, required this.onJump});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onJump,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.keyframe.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
            left: BorderSide(
              color: isActive ? AppColors.keyframe : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.diamond,
                size: 10,
                color: isActive ? AppColors.keyframe : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatTime(kf.time), style: TextStyle(
                    color: isActive ? AppColors.keyframe : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  )),
                  Text(kf.property, style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
            // Easing indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _easingLabel(kf.easing),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toStringAsFixed(2).padLeft(5, '0');
    return '$m:$s';
  }

  String _easingLabel(EasingType e) {
    switch (e) {
      case EasingType.linear: return 'Linear';
      case EasingType.easeIn: return 'Ease In';
      case EasingType.easeOut: return 'Ease Out';
      case EasingType.easeInOut: return 'Ease I/O';
      case EasingType.spring: return 'Spring';
      case EasingType.bounce: return 'Bounce';
    }
  }
}

class _AnimatedPropertiesList extends StatelessWidget {
  final List<Keyframe> keyframes;

  const _AnimatedPropertiesList({required this.keyframes});

  @override
  Widget build(BuildContext context) {
    final props = <String>{};
    for (final kf in keyframes) props.add(kf.property);

    return Container(
      color: AppColors.surfaceElevated,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANIMATED', style: TextStyle(
            color: AppColors.textMuted, fontSize: 9, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: props.map((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.keyframe.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.keyframe.withOpacity(0.4)),
              ),
              child: Text(p, style: const TextStyle(
                color: AppColors.keyframe, fontSize: 10)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
