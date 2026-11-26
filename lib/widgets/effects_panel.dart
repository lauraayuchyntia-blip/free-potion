import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class EffectsPanel extends StatelessWidget {
  const EffectsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layer = provider.selectedLayer;

    if (layer == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppColors.textMuted, size: 32),
            SizedBox(height: 8),
            Text('Select a layer', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            SizedBox(height: 4),
            Text('to add effects', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      );
    }

    final effects = layer.effects;

    return Column(
      children: [
        // Add effect button
        GestureDetector(
          onTap: () => _showAddEffect(context, provider, layer),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.accent, size: 16),
                SizedBox(width: 6),
                Text('Add Effect', style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        ),

        // Effects list
        Expanded(
          child: effects.isEmpty
              ? const Center(
                  child: Text('No effects added', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
                )
              : ListView.builder(
                  itemCount: effects.length,
                  itemBuilder: (ctx, i) => _EffectItem(
                    effect: effects[i],
                    onToggle: () => provider.toggleEffect(layer.id, effects[i].id),
                    onRemove: () => provider.removeEffect(layer.id, effects[i].id),
                    onParamChange: (param, value) =>
                        provider.updateEffectParam(layer.id, effects[i].id, param, value),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddEffect(BuildContext context, EditorProvider provider, ProjectLayer layer) {
    final effectTypes = [
      {'name': 'Blur', 'type': 'blur', 'icon': Icons.blur_on},
      {'name': 'Glow', 'type': 'glow', 'icon': Icons.flare},
      {'name': 'Shadow', 'type': 'shadow', 'icon': Icons.layers_outlined},
      {'name': 'Brightness', 'type': 'brightness', 'icon': Icons.brightness_6},
      {'name': 'Contrast', 'type': 'contrast', 'icon': Icons.contrast},
      {'name': 'Saturation', 'type': 'saturation', 'icon': Icons.palette_outlined},
      {'name': 'Hue', 'type': 'hue', 'icon': Icons.colorize},
      {'name': 'Vignette', 'type': 'vignette', 'icon': Icons.vignette},
      {'name': 'Grain', 'type': 'grain', 'icon': Icons.grain},
      {'name': 'Chromatic Aberration', 'type': 'chromatic', 'icon': Icons.blur_circular},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
          const Divider(color: AppColors.border, height: 1),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: effectTypes.length,
              itemBuilder: (_, i) {
                final e = effectTypes[i];
                return GestureDetector(
                  onTap: () {
                    provider.addEffect(layer.id, provider.createEffect(e['name'] as String, e['type'] as String));
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(e['icon'] as IconData, color: AppColors.accent, size: 22),
                        const SizedBox(height: 6),
                        Text(e['name'] as String, style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EffectItem extends StatefulWidget {
  final EffectLayer effect;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final Function(String, dynamic) onParamChange;

  const _EffectItem({
    required this.effect,
    required this.onToggle,
    required this.onRemove,
    required this.onParamChange,
  });

  @override
  State<_EffectItem> createState() => _EffectItemState();
}

class _EffectItemState extends State<_EffectItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Effect header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(_effectIcon(widget.effect.type),
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.effect.name, style: TextStyle(
                      color: widget.effect.enabled
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                  // Enable toggle
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Container(
                      width: 28,
                      height: 16,
                      decoration: BoxDecoration(
                        color: widget.effect.enabled
                            ? AppColors.accent
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 150),
                        alignment: widget.effect.enabled
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Delete
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
                    ),
                  ),
                  // Expand
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          // Params
          if (_expanded) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: _buildParams(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildParams() {
    final params = widget.effect.params;
    return params.entries.map((entry) {
      final v = entry.value;
      if (v is double || v is int) {
        final dv = (v as num).toDouble();
        return _ParamSlider(
          label: _paramLabel(entry.key),
          value: dv,
          min: _paramMin(entry.key),
          max: _paramMax(entry.key),
          onChanged: (nv) => widget.onParamChange(entry.key, nv),
        );
      }
      return const SizedBox();
    }).toList();
  }

  String _paramLabel(String key) {
    switch (key) {
      case 'intensity': return 'Intensity';
      case 'radius': return 'Radius';
      case 'sigma': return 'Blur';
      case 'spread': return 'Spread';
      case 'offsetX': return 'Offset X';
      case 'offsetY': return 'Offset Y';
      case 'value': return 'Value';
      case 'amount': return 'Amount';
      case 'shift': return 'Shift';
      default: return key;
    }
  }

  double _paramMin(String key) => 0;
  double _paramMax(String key) {
    switch (key) {
      case 'radius': return 50;
      case 'sigma': return 25;
      case 'offsetX':
      case 'offsetY': return 20;
      default: return 100;
    }
  }

  IconData _effectIcon(String type) {
    switch (type) {
      case 'blur': return Icons.blur_on;
      case 'glow': return Icons.flare;
      case 'shadow': return Icons.layers_outlined;
      case 'brightness': return Icons.brightness_6;
      case 'contrast': return Icons.contrast;
      case 'saturation': return Icons.palette_outlined;
      case 'hue': return Icons.colorize;
      case 'vignette': return Icons.vignette;
      case 'grain': return Icons.grain;
      case 'chromatic': return Icons.blur_circular;
      default: return Icons.auto_awesome;
    }
  }
}

class _ParamSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 10)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.border,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(value.toStringAsFixed(0), style: const TextStyle(
            color: AppColors.textMuted, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
