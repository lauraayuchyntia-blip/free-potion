import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';

class PropertiesPanel extends StatelessWidget {
  final VoidCallback? onClose;
  const PropertiesPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layer = provider.selectedLayer;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 16),
                    color: AppColors.textMuted,
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                const Text('Properties', style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                )),
              ],
            ),
          ),

          if (layer == null)
            const Expanded(
              child: Center(
                child: Text('Select a layer', style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  // Layer name
                  _PropSection(title: 'Layer', children: [
                    _PropRow(label: 'Name', child: Text(layer.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                  ]),

                  // Transform
                  _PropSection(title: 'Transform', children: [
                    _SliderProp(
                      label: 'X',
                      value: layer.properties.x,
                      min: -500, max: 500,
                      onChanged: (v) => provider.updateLayerPosition(layer.id, v, layer.properties.y),
                    ),
                    _SliderProp(
                      label: 'Y',
                      value: layer.properties.y,
                      min: -500, max: 500,
                      onChanged: (v) => provider.updateLayerPosition(layer.id, layer.properties.x, v),
                    ),
                    _SliderProp(
                      label: 'Scale X',
                      value: layer.properties.scaleX,
                      min: 0.1, max: 5,
                      onChanged: (v) => provider.updateLayerScale(layer.id, v, layer.properties.scaleY),
                    ),
                    _SliderProp(
                      label: 'Scale Y',
                      value: layer.properties.scaleY,
                      min: 0.1, max: 5,
                      onChanged: (v) => provider.updateLayerScale(layer.id, layer.properties.scaleX, v),
                    ),
                    _SliderProp(
                      label: 'Rotation',
                      value: layer.properties.rotation,
                      min: -180, max: 180,
                      onChanged: (v) => provider.updateLayerRotation(layer.id, v),
                    ),
                    _SliderProp(
                      label: 'Opacity',
                      value: layer.properties.opacity * 100,
                      min: 0, max: 100,
                      onChanged: (v) => provider.updateLayerOpacity(layer.id, v / 100),
                    ),
                  ]),

                  // Text properties
                  if (layer.type.name == 'text')
                    _PropSection(title: 'Text', children: [
                      _PropRow(
                        label: 'Content',
                        child: GestureDetector(
                          onTap: () => _editText(context, layer.id, layer.text ?? ''),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(layer.text ?? '',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                      _SliderProp(
                        label: 'Font Size',
                        value: layer.fontSize ?? 24,
                        min: 8, max: 200,
                        onChanged: (v) {},
                      ),
                    ]),

                  // Effects
                  _PropSection(title: 'Effects', children: [
                    if (layer.effects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No effects applied',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      )
                    else
                      ...layer.effects.map((e) => _EffectRow(effect: e)),
                    GestureDetector(
                      onTap: () => _showEffectsSheet(context, layer.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 14, color: AppColors.accent),
                            const SizedBox(width: 6),
                            const Text('Add Effect', style: TextStyle(
                              color: AppColors.accent, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ]),

                  // Keyframes hint
                  _PropSection(title: 'Animation', children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.diamond_outlined, size: 14, color: AppColors.accentGlow),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text('Tap ◆ in the timeline\nto add keyframes',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _editText(BuildContext context, String layerId, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Text', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          maxLines: 3,
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceElevated,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EditorProvider>().updateLayerText(layerId, ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showEffectsSheet(BuildContext context, String layerId) {
    final effects = [
      {'name': 'Glow', 'type': 'glow', 'icon': Icons.flare},
      {'name': 'Blur', 'type': 'blur', 'icon': Icons.blur_on},
      {'name': 'Color Correct', 'type': 'colorCorrect', 'icon': Icons.tune},
      {'name': 'Shadow', 'type': 'shadow', 'icon': Icons.layers},
      {'name': 'Distort', 'type': 'distort', 'icon': Icons.waves},
      {'name': 'Chromatic', 'type': 'chromatic', 'icon': Icons.colorize},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Add Effect', style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            )),
          ),
          ...effects.map((e) => ListTile(
            leading: Icon(e['icon'] as IconData, color: AppColors.accentGlow, size: 20),
            title: Text(e['name'] as String,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            onTap: () {
              context.read<EditorProvider>().addEffect(
                layerId,
                EffectLayer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: e['name'] as String,
                  type: e['type'] as String,
                ),
              );
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PropSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _PropSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(title.toUpperCase(), style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          )),
        ),
        ...children,
        const Divider(color: AppColors.border, height: 16),
      ],
    );
  }
}

class _PropRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _PropRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SliderProp extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const _SliderProp({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(label, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.accent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 2,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(value.toStringAsFixed(1),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _EffectRow extends StatelessWidget {
  final EffectLayer effect;
  const _EffectRow({required this.effect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: AppColors.accentTeal),
          const SizedBox(width: 6),
          Expanded(child: Text(effect.name,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Switch(
            value: effect.enabled,
            onChanged: (_) {},
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
