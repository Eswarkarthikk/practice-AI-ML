import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  String? _lastLoadedName;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final currentName = appState.profile?.name ?? 'User';
    if (_lastLoadedName != currentName) {
      _nameController.text = currentName;
      _lastLoadedName = currentName;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          children: [
            const SplitTitle(
              first: 'Settings ',
              second: '& Data',
              color: AppColors.blue,
              icon: Icons.settings_suggest_outlined,
              size: 30,
            ),
            const SizedBox(height: 34),
            const _Section(label: 'Data Management'),
            _SettingsRow(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download all your data as JSON',
              onTap: () => _toast('Export will be wired next.'),
            ),
            _SettingsRow(
              icon: Icons.person_outline,
              title: 'Edit Name',
              subtitle: currentName,
              onTap: () => _editName(appState),
            ),
            const SizedBox(height: 28),
            const _Section(label: 'Security'),
            const _SettingsRow(
              icon: Icons.verified_user_outlined,
              title: 'App Lock',
              subtitle:
                  'Always enabled. Unlock with biometrics or your 4-digit PIN.',
              trailing: Icons.lock_outline,
            ),
            _SettingsRow(
              icon: Icons.pin_outlined,
              title: 'Change Lock PIN',
              subtitle: 'Update your 4-digit fallback PIN',
              onTap: () => _toast('Lock features are next on the list.'),
            ),
            const SizedBox(height: 28),
            const _Section(label: 'AI Integration'),
            _SettingsRow(
              icon: Icons.memory_outlined,
              title: 'Gemini API Key',
              subtitle: appState.aiApiKey != null && appState.aiApiKey!.isNotEmpty
                  ? 'Key configured (starts with ${appState.aiApiKey!.substring(0, appState.aiApiKey!.length > 4 ? 4 : appState.aiApiKey!.length)}...)'
                  : 'Not configured',
              onTap: () => _editAiApiKey(appState),
            ),
            const SizedBox(height: 28),
            const _Section(label: 'Notifications'),
            _SettingsRow(
              icon: Icons.notifications_active_outlined,
              title: 'Send Test Reminder',
              subtitle: 'Check notification setup',
              onTap: () => _toast('Alerts can be polished later.'),
            ),
            const SizedBox(height: 28),
            const _Section(label: 'Sources'),
            ...appState.sources.map((source) => _SettingsRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: source.name,
                  subtitle:
                      '${source.type} | Starting ${appState.formatCurrency(source.startingAmount)}',
                  trailing: Icons.delete_outline,
                  onTap: () => appState.removeSource(source.id),
                )),
            _SettingsRow(
              icon: Icons.add_circle_outline,
              title: 'Add Source',
              subtitle: 'Create a new bank, card, or cash source',
              onTap: () => Navigator.of(context).pushNamed('/add-source'),
            ),
            const SizedBox(height: 18),
            _SettingsRow(
              icon: Icons.contrast_outlined,
              title: 'Theme',
              subtitle: appState.themeMode == ThemeMode.light
                  ? 'Light mode'
                  : 'Dark mode',
              onTap: () => appState.setThemeMode(
                appState.themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light,
              ),
            ),
            _SettingsRow(
              icon: Icons.refresh,
              title: 'Reset all data',
              subtitle: 'Clear this device and start again',
              onTap: () => _confirmReset(context, appState),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editAiApiKey(AppStateModel appState) async {
    final controller = TextEditingController(text: appState.aiApiKey ?? '');
    final key = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'AIzaSy...',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Clear', style: TextStyle(color: Colors.red))),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (key == null) return;
    await appState.setAiApiKey(key.isEmpty ? null : key);
  }

  Future<void> _editName(AppStateModel appState) async {
    final controller = TextEditingController(text: _nameController.text);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    await appState.setProfile(name.isEmpty ? 'User' : name);
  }

  Future<void> _confirmReset(
      BuildContext context, AppStateModel appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
            'This clears profile, sources, budgets, and transactions on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.resetAll();
    }
  }
}

class _Section extends StatelessWidget {
  final String label;

  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue, size: 30),
          const SizedBox(width: 18),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      height: 1.25)),
            ]),
          ),
          Icon(trailing ?? Icons.chevron_right,
              color: trailing == Icons.lock_outline
                  ? AppColors.green
                  : AppColors.textSecondary,
              size: 30),
        ],
      ),
    );
  }
}
