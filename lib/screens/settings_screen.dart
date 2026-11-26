import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSave = true;
  bool _showGrid = false;
  bool _snapToGrid = true;
  bool _highQualityPreview = false;
  double _defaultFps = 30;
  String _defaultResolution = '1080×1920';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader('General'),
          _ToggleTile(
            icon: Icons.save_outlined,
            title: 'Auto Save',
            subtitle: 'Automatically save projects',
            value: _autoSave,
            onChanged: (v) => setState(() => _autoSave = v),
          ),
          _SectionHeader('Editor'),
          _ToggleTile(
            icon: Icons.grid_on,
            title: 'Show Grid',
            subtitle: 'Display grid on canvas',
            value: _showGrid,
            onChanged: (v) => setState(() => _showGrid = v),
          ),
          _ToggleTile(
            icon: Icons.grid_4x4,
            title: 'Snap to Grid',
            subtitle: 'Snap layers to grid lines',
            value: _snapToGrid,
            onChanged: (v) => setState(() => _snapToGrid = v),
          ),
          _ToggleTile(
            icon: Icons.hd,
            title: 'High Quality Preview',
            subtitle: 'Better preview, uses more battery',
            value: _highQualityPreview,
            onChanged: (v) => setState(() => _highQualityPreview = v),
          ),
          _SectionHeader('Project Defaults'),
          _SelectTile(
            icon: Icons.aspect_ratio,
            title: 'Default Resolution',
            value: _defaultResolution,
            options: ['1080×1920', '1920×1080', '1080×1080', '2160×3840'],
            onChanged: (v) => setState(() => _defaultResolution = v),
          ),
          _SelectTile(
            icon: Icons.speed,
            title: 'Default Frame Rate',
            value: '${_defaultFps.toInt()} fps',
            options: ['24 fps', '25 fps', '30 fps', '60 fps'],
            onChanged: (v) => setState(() => _defaultFps = double.parse(v.split(' ')[0])),
          ),
          _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
            title: const Text('Version', style: TextStyle(color: AppColors.textPrimary)),
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textMuted)),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: AppColors.textSecondary),
            title: const Text('Free Potion', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Open source motion graphics editor', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title, style: const TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.8,
      )),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        inactiveThumbColor: AppColors.textMuted,
        inactiveTrackColor: AppColors.border,
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SelectTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
        ],
      ),
      onTap: () => _showOptions(context),
    );
  }

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: AppColors.textSecondary)),
            trailing: opt == value
                ? const Icon(Icons.check, color: AppColors.accent)
                : null,
            onTap: () {
              onChanged(opt);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    );
  }
}
