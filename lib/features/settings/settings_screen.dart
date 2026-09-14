import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../core/theme_provider.dart';
import '../../features/home/preferences/home_preferences_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_notification_service.dart';
import '../../services/reset_service.dart';
import '../children/child_management_screen.dart';
import 'data_backup_screen.dart';
import 'home_customization_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResetting = false;
  bool? _notificationsEnabled;
  bool _checkingNotifications = false;
  bool _sendingTestNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotificationStatus();
    });
  }

  Future<void> _refreshNotificationStatus() async {
    if (_checkingNotifications) return;
    if (mounted) setState(() => _checkingNotifications = true);
    final enabled = await AppNotificationService.instance
        .notificationsEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _checkingNotifications = false;
    });
  }

  Future<void> _requestNotificationPermission(AppLocalizations l10n) async {
    if (_checkingNotifications) return;
    setState(() => _checkingNotifications = true);
    final enabled = await AppNotificationService.instance.requestPermissions();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _checkingNotifications = false;
    });
    if (!enabled) _showNotificationSettingsMessage(l10n);
  }

  Future<void> _sendTestNotification(AppLocalizations l10n) async {
    if (_sendingTestNotification) return;
    setState(() => _sendingTestNotification = true);
    final sent = await AppNotificationService.instance.showTestNotification(
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
    );
    if (!mounted) return;
    setState(() {
      _sendingTestNotification = false;
      _notificationsEnabled = sent;
    });
    if (sent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.testNotificationSent)));
    } else {
      _showNotificationSettingsMessage(l10n);
    }
  }

  void _showNotificationSettingsMessage(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.reminderCouldNotBeScheduled),
        action: SnackBarAction(
          label: l10n.openSettings,
          onPressed: AppNotificationService.instance.openNotificationSettings,
        ),
      ),
    );
  }

  Future<void> _handleReset(AppLocalizations l10n) async {
    if (_isResetting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmResetTitle),
        content: Text(l10n.confirmResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isResetting = true);
    try {
      await ResetService.clearAll();
      if (!mounted) return;
      context.read<HomePreferencesProvider>().resetAfterAppDataCleared();
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.operationFailed)));
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();
    final children = context.watch<ActiveChildProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _section(
            children: [
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: Text(l10n.premiumTitle),
                subtitle: Text(
                  premium.isPremium ? l10n.premiumActive : l10n.comingSoon,
                ),
                trailing: premium.isPremium
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.hourglass_top_rounded),
                onTap: premium.isPremium
                    ? null
                    : () => PremiumAccess.open(
                        context,
                        feature: PremiumFeature.advancedAnalytics,
                        builder: (_) => const SizedBox.shrink(),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notificationSettings),
                subtitle: Text(
                  _notificationsEnabled == null
                      ? l10n.notificationsNotChecked
                      : _notificationsEnabled!
                      ? l10n.notificationsEnabled
                      : l10n.notificationsDenied,
                ),
                trailing: _checkingNotifications
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _notificationsEnabled == true
                            ? Icons.check_circle
                            : Icons.chevron_right,
                        color: _notificationsEnabled == true
                            ? Colors.green
                            : null,
                      ),
                onTap: () => _notificationsEnabled == true
                    ? _refreshNotificationStatus()
                    : _requestNotificationPermission(l10n),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notification_add_outlined),
                title: Text(l10n.sendTestNotification),
                subtitle: Text(l10n.sendTestNotificationDescription),
                enabled: !_sendingTestNotification,
                trailing: _sendingTestNotification
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                onTap: () => _sendTestNotification(l10n),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicyTitle),
                subtitle: Text(l10n.privacyPolicySubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutLeyumiTitle),
                subtitle: Text(l10n.aboutLeyumiBody),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(l10n.dataManagement),
                subtitle: Text(l10n.dataManagementSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DataBackupScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(l10n.childProfiles),
                subtitle: Text(
                  '${children.profiles.length} - ${children.activeChild?.name ?? l10n.activeChild}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChildManagementScreen(),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined),
                title: Text(l10n.customizeHomeTitle),
                subtitle: Text(l10n.customizeHomeSettingsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeCustomizationScreen(),
                  ),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.darkModeDescription),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section(
            children: [
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(l10n.resetApp),
                subtitle: Text(l10n.resetAppDescription),
                enabled: !_isResetting,
                trailing: _isResetting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => _handleReset(l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
