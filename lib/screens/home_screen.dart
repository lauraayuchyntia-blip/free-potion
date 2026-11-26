import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';
import 'editor_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Tab bar like Alight Motion
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              indicatorWeight: 2,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'My Work'),
                Tab(text: 'Templates'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MyWorkTab(provider: provider),
                _TemplatesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewProjectDialog(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'Free Potion',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          onPressed: () => _showSearchDialog(context),
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          tooltip: 'Settings',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Search Projects', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Project name...',
            prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          ),
          onChanged: (val) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'My Project');
    int selectedRatio = 0;
    final ratios = [
      {'label': 'Reels / TikTok', 'icon': '📱', 'w': 1080, 'h': 1920, 'sub': '9:16 • 1080×1920'},
      {'label': 'YouTube / Landscape', 'icon': '🎬', 'w': 1920, 'h': 1080, 'sub': '16:9 • 1920×1080'},
      {'label': 'Instagram Square', 'icon': '📸', 'w': 1080, 'h': 1080, 'sub': '1:1 • 1080×1080'},
      {'label': 'Instagram Story', 'icon': '✨', 'w': 1080, 'h': 1920, 'sub': '9:16 • 1080×1920'},
      {'label': 'Twitter / X Banner', 'icon': '🌐', 'w': 1500, 'h': 500, 'sub': '3:1 • 1500×500'},
      {'label': 'Custom Size', 'icon': '⚙️', 'w': 1080, 'h': 1080, 'sub': 'Set manually'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scroll) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Text('New Project', style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        prefixIcon: Icon(Icons.movie_creation_outlined, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Canvas Size', style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
                    const SizedBox(height: 10),
                    ...List.generate(ratios.length, (i) => GestureDetector(
                      onTap: () => setState(() => selectedRatio = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedRatio == i
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedRatio == i ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(ratios[i]['icon'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ratios[i]['label'] as String, style: TextStyle(
                                    color: selectedRatio == i ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  )),
                                  Text(ratios[i]['sub'] as String, style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  )),
                                ],
                              ),
                            ),
                            if (selectedRatio == i)
                              const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final ratio = ratios[selectedRatio];
                          final provider = context.read<EditorProvider>();
                          provider.createNewProject(
                            name: nameCtrl.text.trim().isEmpty ? 'My Project' : nameCtrl.text.trim(),
                            width: ratio['w'] as int,
                            height: ratio['h'] as int,
                          );
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EditorScreen(),
                          ));
                        },
                        child: const Text('Create Project', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── My Work Tab ─────────────────────────────────────────────────────────────

class _MyWorkTab extends StatelessWidget {
  final EditorProvider provider;
  const _MyWorkTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.projects.isEmpty) {
      return _EmptyState(
        onTap: () {},
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
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
          onLongPress: () => _showProjectMenu(context, proj, provider),
        );
      },
    );
  }

  void _showProjectMenu(BuildContext context, Project project, EditorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(project.name, style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
            ),
            const Divider(color: AppColors.border, height: 1),
            _MenuTile(
              icon: Icons.edit_outlined,
              label: 'Rename',
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, project, provider);
              },
            ),
            _MenuTile(
              icon: Icons.copy_outlined,
              label: 'Duplicate',
              onTap: () {
                provider.duplicateProject(project.id);
                Navigator.pop(ctx);
              },
            ),
            _MenuTile(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: AppColors.danger,
              onTap: () {
                provider.deleteProject(project.id);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Project project, EditorProvider provider) {
    final ctrl = TextEditingController(text: project.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Project', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Project name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.renameProject(project.id, ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Rename', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ─── Templates Tab ───────────────────────────────────────────────────────────

class _TemplatesTab extends StatelessWidget {
  final List<Map<String, dynamic>> _templates = const [
    {'name': 'Intro Animation', 'category': 'Motion', 'icon': '🎬', 'w': 1080, 'h': 1920},
    {'name': 'Text Reveal', 'category': 'Text', 'icon': '✍️', 'w': 1080, 'h': 1080},
    {'name': 'Logo Sting', 'category': 'Branding', 'icon': '⭐', 'w': 1920, 'h': 1080},
    {'name': 'Story Template', 'category': 'Social', 'icon': '📱', 'w': 1080, 'h': 1920},
    {'name': 'Lower Third', 'category': 'Title', 'icon': '📝', 'w': 1920, 'h': 1080},
    {'name': 'Countdown Timer', 'category': 'Motion', 'icon': '⏱️', 'w': 1080, 'h': 1080},
    {'name': 'Particle Effect', 'category': 'FX', 'icon': '✨', 'w': 1080, 'h': 1920},
    {'name': 'Glitch Text', 'category': 'Text', 'icon': '⚡', 'w': 1080, 'h': 1920},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: ['All', 'Motion', 'Text', 'Social', 'Branding', 'FX'].map((cat) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(label: cat),
              ),
            ).toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, i) {
              final t = _templates[i];
              return _TemplateCard(
                name: t['name'] as String,
                category: t['category'] as String,
                icon: t['icon'] as String,
                onTap: () {
                  final provider = context.read<EditorProvider>();
                  provider.createNewProject(
                    name: t['name'] as String,
                    width: t['w'] as int,
                    height: t['h'] as int,
                  );
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const EditorScreen(),
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                ),
                child: Stack(
                  children: [
                    // Thumbnail placeholder
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.movie_creation_outlined,
                            color: AppColors.accentGlow, size: 28),
                      ),
                    ),
                    // Aspect ratio badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${project.width}×${project.height}',
                          style: const TextStyle(color: Colors.white70, fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(project.updatedAt),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TemplateCard extends StatelessWidget {
  final String name;
  final String category;
  final String icon;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.name,
    required this.category,
    required this.icon,
    required this.onTap,
  });

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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.3),
                      AppColors.accentTeal.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 36)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(category, style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: _selected ? AppColors.accent : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentTeal],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('No projects yet', style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          )),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first\nmotion graphics project',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return ListTile(
      leading: Icon(icon, color: c, size: 20),
      title: Text(label, style: TextStyle(color: c, fontSize: 15)),
      onTap: onTap,
    );
  }
}
