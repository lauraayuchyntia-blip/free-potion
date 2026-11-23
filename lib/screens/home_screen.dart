import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Free Potion', style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1040), Color(0xFF0D2040)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✨ Free Potion', style: TextStyle(
                        color: AppColors.accentGlow,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                      const SizedBox(height: 4),
                      const Text('Motion Graphics & Video Editor\nNo watermark. No paywall. Free forever.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
                const Text('🧪', style: TextStyle(fontSize: 40)),
              ],
            ),
          ),

          // New Project Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showNewProjectDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Templates row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Templates', style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                )),
                const Spacer(),
                Text('See all', style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                )),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _TemplateCard(label: '📱 Reels 9:16', onTap: () => _createWithRatio(context, 1080, 1920)),
                _TemplateCard(label: '🎬 Video 16:9', onTap: () => _createWithRatio(context, 1920, 1080)),
                _TemplateCard(label: '📸 Square 1:1', onTap: () => _createWithRatio(context, 1080, 1080)),
                _TemplateCard(label: '🌐 Banner', onTap: () => _createWithRatio(context, 1200, 628)),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Recent Projects', style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                )),
                const Spacer(),
                if (provider.projects.isNotEmpty)
                  Text('${provider.projects.length} projects', style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  )),
              ],
            ),
          ),

          Expanded(
            child: provider.projects.isEmpty
                ? _EmptyProjectsState(onNewProject: () => _showNewProjectDialog(context))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: provider.projects.length,
                    itemBuilder: (context, i) {
                      final proj = provider.projects[i];
                      return _ProjectCard(
                        project: proj,
                        onTap: () {
                          provider.openProject(proj);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EditorScreen(),
                          ));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'My Project');
    int selectedRatio = 0;
    final ratios = [
      {'label': 'Reels 9:16', 'w': 1080, 'h': 1920},
      {'label': 'Video 16:9', 'w': 1920, 'h': 1080},
      {'label': 'Square 1:1', 'w': 1080, 'h': 1080},
      {'label': 'Custom', 'w': 1080, 'h': 1080},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Project', style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              )),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Aspect Ratio', style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(ratios.length, (i) => ChoiceChip(
                  label: Text(ratios[i]['label'] as String),
                  selected: selectedRatio == i,
                  onSelected: (_) => setState(() => selectedRatio = i),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    color: selectedRatio == i ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final ratio = ratios[selectedRatio];
                    final provider = context.read<EditorProvider>();
                    provider.createNewProject(
                      name: nameCtrl.text.trim().isEmpty ? 'New Project' : nameCtrl.text.trim(),
                      width: ratio['w'] as int,
                      height: ratio['h'] as int,
                    );
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const EditorScreen(),
                    ));
                  },
                  child: const Text('Create Project'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _createWithRatio(BuildContext context, int w, int h) {
    final provider = context.read<EditorProvider>();
    provider.createNewProject(width: w, height: h);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen()));
  }
}

class _TemplateCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TemplateCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.2),
                      AppColors.accentTeal.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.movie_creation_outlined,
                    color: AppColors.accentGlow, size: 32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('${project.width}×${project.height}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  final VoidCallback onNewProject;
  const _EmptyProjectsState({required this.onNewProject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧪', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No projects yet', style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          )),
          const SizedBox(height: 6),
          const Text('Create your first motion graphics project',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onNewProject,
            child: const Text('Create Project →',
              style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
