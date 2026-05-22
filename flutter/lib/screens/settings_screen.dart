import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
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

    final isLandscape = Responsive.isLandscape(context);

    if (isLandscape) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r(context), vertical: 12.r(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(right: 16.r(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SplitTitle(
                          first: 'Settings ',
                          second: '& Data',
                          color: AppColors.blue,
                          icon: Icons.settings_suggest_outlined,
                          size: 20.r(context),
                        ),
                        SizedBox(height: 18.r(context)),
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
                        SizedBox(height: 18.r(context)),
                        const _Section(label: 'Security'),
                        _SettingsRow(
                          icon: Icons.verified_user_outlined,
                          title: 'App Lock',
                          subtitle: appState.appLockEnabled
                              ? 'Enabled. Secured with biometrics/PIN'
                              : 'Disabled. Turn on lock to secure your wallet',
                          trailing: appState.appLockEnabled ? Icons.toggle_on : Icons.toggle_off,
                          trailingColor: appState.appLockEnabled ? AppColors.green : AppColors.textSecondary,
                          onTap: () {
                            if (appState.appLockEnabled) {
                              appState.setAppLockEnabled(false);
                              appState.setAppLockPin(null);
                            } else {
                              appState.setAppLockEnabled(false);
                              appState.setAppLockPin(null);
                            }
                          },
                        ),
                        _SettingsRow(
                          icon: Icons.pin_outlined,
                          title: 'Change Lock PIN',
                          subtitle: 'Update your 4-digit fallback PIN',
                          onTap: () {
                            appState.setAppLockEnabled(false);
                            appState.setAppLockPin(null);
                          },
                        ),
                        SizedBox(height: 18.r(context)),
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
                ),
                // Vertical Divider
                Container(
                  width: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  margin: EdgeInsets.symmetric(horizontal: 4.r(context)),
                ),
                // Right Column
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(left: 16.r(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Section(label: 'AI Integration'),
                        _SettingsRow(
                          icon: Icons.memory_outlined,
                          title: 'Gemini API Key',
                          subtitle: appState.aiApiKey != null && appState.aiApiKey!.isNotEmpty
                              ? 'Key configured (starts with ${appState.aiApiKey!.substring(0, appState.aiApiKey!.length > 4 ? 4 : appState.aiApiKey!.length)}...)'
                              : 'Not configured',
                          onTap: () => _editAiApiKey(appState),
                        ),
                        SizedBox(height: 18.r(context)),
                        const _Section(label: 'Notifications'),
                        _SettingsRow(
                          icon: Icons.notifications_active_outlined,
                          title: 'Send Test Reminder',
                          subtitle: 'Check notification setup',
                          onTap: () => _toast('Alerts can be polished later.'),
                        ),
                        SizedBox(height: 18.r(context)),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.r(context), 24.r(context), 20.r(context), 110.r(context)),
          children: [
            SplitTitle(
              first: 'Settings ',
              second: '& Data',
              color: AppColors.blue,
              icon: Icons.settings_suggest_outlined,
              size: 20.r(context),
            ),
            SizedBox(height: 18.r(context)),
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
            SizedBox(height: 18.r(context)),
            const _Section(label: 'Security'),
            _SettingsRow(
              icon: Icons.verified_user_outlined,
              title: 'App Lock',
              subtitle: appState.appLockEnabled
                  ? 'Enabled. Secured with biometrics/PIN'
                  : 'Disabled. Turn on lock to secure your wallet',
              trailing: appState.appLockEnabled ? Icons.toggle_on : Icons.toggle_off,
              trailingColor: appState.appLockEnabled ? AppColors.green : AppColors.textSecondary,
              onTap: () {
                if (appState.appLockEnabled) {
                  appState.setAppLockEnabled(false);
                  appState.setAppLockPin(null);
                } else {
                  appState.setAppLockEnabled(false);
                  appState.setAppLockPin(null);
                }
              },
            ),
            _SettingsRow(
              icon: Icons.pin_outlined,
              title: 'Change Lock PIN',
              subtitle: 'Update your 4-digit fallback PIN',
              onTap: () {
                appState.setAppLockEnabled(false);
                appState.setAppLockPin(null);
              },
            ),
            SizedBox(height: 18.r(context)),
            const _Section(label: 'AI Integration'),
            _SettingsRow(
              icon: Icons.memory_outlined,
              title: 'Gemini API Key',
              subtitle: appState.aiApiKey != null && appState.aiApiKey!.isNotEmpty
                  ? 'Key configured (starts with ${appState.aiApiKey!.substring(0, appState.aiApiKey!.length > 4 ? 4 : appState.aiApiKey!.length)}...)'
                  : 'Not configured',
              onTap: () => _editAiApiKey(appState),
            ),
            SizedBox(height: 18.r(context)),
            const _Section(label: 'Notifications'),
            _SettingsRow(
              icon: Icons.notifications_active_outlined,
              title: 'Send Test Reminder',
              subtitle: 'Check notification setup',
              onTap: () => _toast('Alerts can be polished later.'),
            ),
            SizedBox(height: 18.r(context)),
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
            SizedBox(height: 18.r(context)),
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
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r(context))),
        title: Text(
          'Gemini API Key',
          style: TextStyle(
            fontSize: 18.r(context),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.r(context)),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14.r(context), color: AppColors.textPrimary),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'API Key',
              labelStyle: TextStyle(fontSize: 12.r(context)),
              hintText: 'AIzaSy...',
              hintStyle: TextStyle(fontSize: 12.r(context)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 13.r(context), color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
            ),
            onPressed: () => Navigator.of(context).pop(''),
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontSize: 13.r(context)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size(80.r(context), 38.r(context)),
              padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
            ),
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(fontSize: 13.r(context)),
            ),
          ),
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
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r(context))),
        title: Text(
          'Edit Name',
          style: TextStyle(
            fontSize: 18.r(context),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.r(context)),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14.r(context), color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(fontSize: 12.r(context)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 13.r(context), color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size(80.r(context), 38.r(context)),
              padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
            ),
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(fontSize: 13.r(context)),
            ),
          ),
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
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r(context))),
        title: Text(
          'Reset all data?',
          style: TextStyle(
            fontSize: 18.r(context),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.r(context)),
          child: Text(
            'This clears profile, sources, budgets, and transactions on this device.',
            style: TextStyle(fontSize: 13.r(context), color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 12.r(context), vertical: 8.r(context)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 13.r(context), color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size(80.r(context), 38.r(context)),
              padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 8.r(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r(context))),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Reset',
              style: TextStyle(fontSize: 13.r(context)),
            ),
          ),
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
      padding: EdgeInsets.only(bottom: 12.r(context)),
      child: Text(label,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.r(context),
              fontWeight: FontWeight.w900)),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      margin: EdgeInsets.only(bottom: 12.r(context)),
      padding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue, size: 20.r(context)),
          SizedBox(width: 14.r(context)),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13.r(context), fontWeight: FontWeight.w900)),
              SizedBox(height: 4.r(context)),
              Text(subtitle,
                  style: GoogleFonts.spaceMono(
                      color: AppColors.textSecondary,
                      fontSize: 11.r(context),
                      height: 1.25)),
            ]),
          ),
          Icon(trailing ?? Icons.chevron_right,
              color: trailingColor ?? AppColors.textSecondary,
              size: 20.r(context)),
        ],
      ),
    );
  }
}
