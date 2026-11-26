import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';

class ExportSheet extends StatefulWidget {
  const ExportSheet({super.key});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  String _format = 'MP4';
  String _quality = '1080p';
  String _fps = '30';
  bool _includeAudio = true;
  bool _isExporting = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.file_download_outlined, color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Export Project', style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(20),
                children: [
                  // Project info
                  if (project != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, Color(0xFF9F67FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.movie_outlined, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(project.name, style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                                const SizedBox(height: 2),
                                Text(
                                  '${project.width}×${project.height} · ${project.duration.toStringAsFixed(1)}s · ${project.layers.length} layers',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Format selector
                  _SectionLabel('Format'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['MP4', 'GIF', 'MOV', 'WEBM'].map((f) {
                      final active = f == _format;
                      return GestureDetector(
                        onTap: () => setState(() => _format = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active ? AppColors.accent : AppColors.border),
                          ),
                          child: Text(f, style: TextStyle(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          )),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Quality
                  _SectionLabel('Quality'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['720p', '1080p', '4K'].map((q) {
                      final active = q == _quality;
                      return GestureDetector(
                        onTap: () => setState(() => _quality = q),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active ? AppColors.accent : AppColors.border),
                          ),
                          child: Text(q, style: TextStyle(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          )),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // FPS
                  _SectionLabel('Frame Rate'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['24', '25', '30', '60'].map((f) {
                      final active = f == _fps;
                      return GestureDetector(
                        onTap: () => setState(() => _fps = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active ? AppColors.accent : AppColors.border),
                          ),
                          child: Text('$f fps', style: TextStyle(
                            color: active ? Colors.white : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          )),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Options
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      title: const Text('Include Audio', style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
                      subtitle: const Text('Export with audio tracks', style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                      value: _includeAudio,
                      onChanged: (v) => setState(() => _includeAudio = v),
                      activeColor: AppColors.accent,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Export progress
                  if (_isExporting) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Exporting…', style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                              ),
                              Text('${(_progress * 100).toInt()}%', style: const TextStyle(
                                color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Export button
                  if (!_isExporting)
                    GestureDetector(
                      onTap: _startExport,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF9F67FF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_download_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Export as $_format · $_quality',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startExport() async {
    setState(() {
      _isExporting = true;
      _progress = 0;
    });

    // Simulated export progress (actual rendering engine would go here)
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() => _progress = i / 20);
    }

    if (!mounted) return;

    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Exported as $_format ($_quality)'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ));
  }
}
