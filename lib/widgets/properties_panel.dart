import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final layer = provider.selectedLayer;

    if (layer == null) return const SizedBox();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 36,
            color: AppColors.surfaceElevated,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('Properties', style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
                ),
                GestureDetector(
                  onTap: () => provider.selectLayer(null),
                  child: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                // Layer name
                _PropGroup('Layer', [
                  _TextFieldProp(
                    label: 'Name',
                    value: layer.name,
                    onChanged: (v) {
                      layer.name = v;
                    },
                  ),
                ]),

                // Transform
                _PropGroup('Transform', [
                  _SliderProp(
                    label: 'X',
                    value: layer.properties.x,
                    min: -1080,
                    max: 1080,
                    onChanged: (v) => provider.updateLayerPosition(layer.id, v, layer.properties.y),
                    displayValue: layer.properties.x.toStringAsFixed(0),
                  ),
                  _SliderProp(
                    label: 'Y',
                    value: layer.properties.y,
                    min: -1920,
                    max: 1920,
                    onChanged: (v) => provider.updateLayerPosition(layer.id, layer.properties.x, v),
                    displayValue: layer.properties.y.toStringAsFixed(0),
                  ),
                  _SliderProp(
                    label: 'Scale X',
                    value: layer.properties.scaleX,
                    min: 0.01,
                    max: 5,
                    onChanged: (v) => provider.updateLayerScale(layer.id, v, layer.properties.scaleY),
                    displayValue: '${(layer.properties.scaleX * 100).toStringAsFixed(0)}%',
                  ),
                  _SliderProp(
                    label: 'Scale Y',
                    value: layer.properties.scaleY,
                    min: 0.01,
                    max: 5,
                    onChanged: (v) => provider.updateLayerScale(layer.id, layer.properties.scaleX, v),
                    displayValue: '${(layer.properties.scaleY * 100).toStringAsFixed(0)}%',
                  ),
                  _SliderProp(
                    label: 'Rotation',
                    value: layer.properties.rotation,
                    min: -360,
                    max: 360,
                    onChanged: (v) => provider.updateLayerRotation(layer.id, v),
                    displayValue: '${layer.properties.rotation.toStringAsFixed(1)}°',
                  ),
                  _SliderProp(
                    label: 'Opacity',
                    value: layer.properties.opacity * 100,
                    min: 0,
                    max: 100,
                    onChanged: (v) => provider.updateLayerOpacity(layer.id, v / 100),
                    displayValue: '${(layer.properties.opacity * 100).toStringAsFixed(0)}%',
                  ),
                ]),

                // Timing
                _PropGroup('Timing', [
                  _SliderProp(
                    label: 'Start',
                    value: layer.startTime,
                    min: 0,
                    max: (provider.currentProject?.duration ?? 10) - 0.1,
                    onChanged: (v) => provider.updateLayerTiming(layer.id, v, layer.endTime),
                    displayValue: '${layer.startTime.toStringAsFixed(2)}s',
                  ),
                  _SliderProp(
                    label: 'End',
                    value: layer.endTime,
                    min: layer.startTime + 0.1,
                    max: provider.currentProject?.duration ?? 10,
                    onChanged: (v) => provider.updateLayerTiming(layer.id, layer.startTime, v),
                    displayValue: '${layer.endTime.toStringAsFixed(2)}s',
                  ),
                ]),

                // Type-specific props
                if (layer.type == LayerType.text) ...[
                  _PropGroup('Text', [
                    _TextFieldProp(
                      label: 'Content',
                      value: layer.text ?? '',
                      onChanged: (v) => provider.updateLayerText(layer.id, v),
                    ),
                    _SliderProp(
                      label: 'Font Size',
                      value: layer.fontSize ?? 48,
                      min: 8,
                      max: 300,
                      onChanged: (v) => provider.updateLayerFontSize(layer.id, v),
                      displayValue: '${(layer.fontSize ?? 48).toStringAsFixed(0)}px',
                    ),
                    _ColorProp(
                      label: 'Color',
                      color: layer.color ?? Colors.white,
                      onChanged: (c) => provider.updateLayerColor(layer.id, c),
                    ),
                    _FontFamilyProp(
                      value: layer.fontFamily ?? 'Inter',
                      onChanged: (f) => provider.updateLayerFontFamily(layer.id, f),
                    ),
                  ]),
                ],

                if (layer.type == LayerType.shape) ...[
                  _PropGroup('Shape', [
                    _ColorProp(
                      label: 'Fill Color',
                      color: layer.color ?? AppColors.accent,
                      onChanged: (c) => provider.updateLayerColor(layer.id, c),
                    ),
                    _ShapeTypeProp(
                      value: layer.shapeType ?? 'rectangle',
                      onChanged: (s) => provider.updateLayerShapeType(layer.id, s),
                    ),
                  ]),
                ],

                if (layer.type == LayerType.audio || layer.type == LayerType.video) ...[
                  _PropGroup('Audio', [
                    _SliderProp(
                      label: 'Volume',
                      value: (layer.volume ?? 1.0) * 100,
                      min: 0,
                      max: 100,
                      onChanged: (v) => provider.updateLayerVolume(layer.id, v / 100),
                      displayValue: '${((layer.volume ?? 1.0) * 100).toStringAsFixed(0)}%',
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prop Widgets ─────────────────────────────────────────────────────────────

class _PropGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PropGroup(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 10),
          child: Text(title.toUpperCase(), style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          )),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SliderProp extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String displayValue;

  const _SliderProp({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(label, style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
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
                width: 44,
                child: Text(displayValue, style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }
}

class _TextFieldProp extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TextFieldProp({required this.label, required this.value, required this.onChanged});

  @override
  State<_TextFieldProp> createState() => _TextFieldPropState();
}

class _TextFieldPropState extends State<_TextFieldProp> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextFieldProp old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(widget.label, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorProp extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorProp({required this.label, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
          GestureDetector(
            onTap: () => _pickColor(context),
            child: Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context) {
    Color tempColor = color;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              onChanged(tempColor);
              Navigator.pop(ctx);
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _FontFamilyProp extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _FontFamilyProp({required this.value, required this.onChanged});

  static const _fonts = ['Inter', 'Roboto', 'Montserrat', 'Poppins', 'Oswald', 'Raleway', 'Ubuntu', 'Nunito'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 60,
            child: Text('Font', style: TextStyle(color: AppColors.textSecondary, fontSize: 11))),
          Expanded(
            child: GestureDetector(
              onTap: () => _pick(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(value, style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 12))),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Font Family', style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          ..._fonts.map((f) => ListTile(
            title: Text(f, style: TextStyle(color: AppColors.textPrimary, fontFamily: f)),
            trailing: f == value ? const Icon(Icons.check, color: AppColors.accent) : null,
            onTap: () { onChanged(f); Navigator.pop(ctx); },
          )),
        ],
      ),
    );
  }
}

class _ShapeTypeProp extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ShapeTypeProp({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final shapes = [
      {'id': 'rectangle', 'icon': Icons.crop_square, 'label': 'Rectangle'},
      {'id': 'circle', 'icon': Icons.circle_outlined, 'label': 'Circle'},
      {'id': 'triangle', 'icon': Icons.change_history, 'label': 'Triangle'},
      {'id': 'star', 'icon': Icons.star_outline, 'label': 'Star'},
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shape Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            children: shapes.map((s) {
              final id = s['id'] as String;
              final icon = s['icon'] as IconData;
              final active = id == value;
              return GestureDetector(
                onTap: () => onChanged(id),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent.withOpacity(0.2) : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: active ? AppColors.accent : AppColors.border),
                  ),
                  child: Icon(icon, size: 18, color: active ? AppColors.accent : AppColors.textSecondary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
