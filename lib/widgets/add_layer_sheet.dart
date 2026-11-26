import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/editor_provider.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';

class AddLayerSheet extends StatelessWidget {
  const AddLayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.accent, size: 20),
                  SizedBox(width: 10),
                  Text('Add Layer', style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionLabel('Media'),
                  _LayerGrid([
                    _LayerOption(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      color: const Color(0xFF3B82F6),
                      onTap: () => _pickVideo(context),
                    ),
                    _LayerOption(
                      icon: Icons.image_outlined,
                      label: 'Image',
                      color: const Color(0xFF10B981),
                      onTap: () => _pickImage(context),
                    ),
                    _LayerOption(
                      icon: Icons.music_note_outlined,
                      label: 'Audio',
                      color: const Color(0xFFEC4899),
                      onTap: () => _pickAudio(context),
                    ),
                    _LayerOption(
                      icon: Icons.code_outlined,
                      label: 'SVG',
                      color: const Color(0xFFEF4444),
                      onTap: () => _pickSvg(context),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _SectionLabel('Create'),
                  _LayerGrid([
                    _LayerOption(
                      icon: Icons.text_fields,
                      label: 'Text',
                      color: const Color(0xFFF59E0B),
                      onTap: () => _addText(context),
                    ),
                    _LayerOption(
                      icon: Icons.crop_square_outlined,
                      label: 'Shape',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _addShape(context),
                    ),
                    _LayerOption(
                      icon: Icons.auto_awesome,
                      label: 'Effect',
                      color: const Color(0xFF06B6D4),
                      onTap: () => _addEffectLayer(context),
                    ),
                    _LayerOption(
                      icon: Icons.gradient,
                      label: 'Gradient',
                      color: const Color(0xFF6366F1),
                      onTap: () => _addGradient(context),
                    ),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file != null && context.mounted) {
      context.read<EditorProvider>().addLayer(
        name: 'Video',
        type: LayerType.video,
        filePath: file.path,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && context.mounted) {
      context.read<EditorProvider>().addLayer(
        name: 'Image',
        type: LayerType.image,
        filePath: file.path,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickAudio(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty && context.mounted) {
      context.read<EditorProvider>().addLayer(
        name: result.files.first.name,
        type: LayerType.audio,
        filePath: result.files.first.path,
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickSvg(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty && context.mounted) {
      String? svgContent;
      if (result.files.first.path != null) {
        svgContent = await File(result.files.first.path!).readAsString();
      }
      context.read<EditorProvider>().addLayer(
        name: result.files.first.name,
        type: LayerType.svg,
        filePath: result.files.first.path,
        svgContent: svgContent,
      );
      Navigator.pop(context);
    }
  }

  void _addText(BuildContext context) {
    final provider = context.read<EditorProvider>();
    _showTextDialog(context, (text) {
      provider.addLayer(
        name: 'Text',
        type: LayerType.text,
        text: text,
      );
      Navigator.pop(context);
    });
  }

  void _showTextDialog(BuildContext context, Function(String) onDone) {
    final ctrl = TextEditingController(text: 'Your Text Here');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Text', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Enter text…'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDone(ctrl.text);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _addShape(BuildContext context) {
    final shapes = [
      {'label': 'Rectangle', 'type': 'rectangle', 'icon': Icons.crop_square_outlined},
      {'label': 'Circle', 'type': 'circle', 'icon': Icons.circle_outlined},
      {'label': 'Triangle', 'type': 'triangle', 'icon': Icons.change_history},
      {'label': 'Star', 'type': 'star', 'icon': Icons.star_outline},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Shape', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: shapes.map((s) => ListTile(
            leading: Icon(s['icon'] as IconData, color: AppColors.accent),
            title: Text(s['label'] as String,
              style: const TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              context.read<EditorProvider>().addLayer(
                name: s['label'] as String,
                type: LayerType.shape,
                shapeType: s['type'] as String,
              );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _addEffectLayer(BuildContext context) {
    context.read<EditorProvider>().addLayer(
      name: 'Effect Layer',
      type: LayerType.effect,
    );
    Navigator.pop(context);
  }

  void _addGradient(BuildContext context) {
    context.read<EditorProvider>().addLayer(
      name: 'Gradient',
      type: LayerType.shape,
      shapeType: 'gradient',
    );
    Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text.toUpperCase(), style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      )),
    );
  }
}

class _LayerGrid extends StatelessWidget {
  final List<_LayerOption> options;
  const _LayerGrid(this.options);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: options,
    );
  }
}

class _LayerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LayerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
