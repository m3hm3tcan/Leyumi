import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../core/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_notification_service.dart';
import '../../services/reset_service.dart';
import '../children/child_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _notificationsEnabled;
  bool _loadingNotifications = true;
  bool _sendingTest = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await CareNotificationService.instance
        .areNotificationsEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotifications = false;
    });
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _loadingNotifications = true);
    await CareNotificationService.instance.requestPermissions();
    await _loadNotificationStatus();
  }

  Future<void> _sendTestNotification(AppLocalizations l10n) async {
    setState(() => _sendingTest = true);
    final shown = await CareNotificationService.instance.showTestNotification(
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
    );
    await _loadNotificationStatus();
    if (!mounted) return;
    setState(() => _sendingTest = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shown ? l10n.testNotificationSent : l10n.notificationsDenied,
        ),
      ),
    );
  }

  Future<void> _handleReset(AppLocalizations l10n) async {
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
    await ResetService.clearAll();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
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
                  premium.isPremium ? l10n.premiumActive : l10n.premiumInactive,
                ),
                trailing: premium.isPremium
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.lock),
                onTap: premium.isPremium
                    ? null
                    : () => PremiumAccess.open(
                        context,
                        feature: PremiumFeature.smartReminders,
                        builder: (_) => const SizedBox.shrink(),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _notificationSection(l10n, premium),
          const SizedBox(height: 14),
          _section(
            children: [
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
                onTap: () => _handleReset(l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notificationSection(AppLocalizations l10n, PremiumProvider premium) {
    final isPremium = premium.hasAccess(PremiumFeature.smartReminders);
    final statusText = _loadingNotifications
        ? l10n.loading
        : _notificationStatusText(l10n);
    final statusColor = _notificationsEnabled == true
        ? Colors.green
        : _notificationsEnabled == false
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return _section(
      children: [
        ListTile(
          leading: Icon(
            isPremium ? Icons.notifications_active : Icons.notifications_off,
            color: isPremium ? statusColor : null,
          ),
          title: Text(l10n.notificationSettings),
          subtitle: Text(
            isPremium ? statusText : l10n.notificationsPremiumHint,
          ),
          trailing: isPremium
              ? _loadingNotifications
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _notificationsEnabled == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: statusColor,
                      )
              : const Icon(Icons.lock),
          onTap: isPremium
              ? _requestNotificationPermission
              : () => PremiumAccess.open(
                  context,
                  feature: PremiumFeature.smartReminders,
                  builder: (_) => const SizedBox.shrink(),
                ),
        ),
        if (isPremium) ...[
          const Divider(height: 1),
          ListTile(
            enabled: !_sendingTest,
            leading: const Icon(Icons.notification_add),
            title: Text(l10n.sendTestNotification),
            subtitle: Text(l10n.sendTestNotificationDescription),
            trailing: _sendingTest
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _sendingTest ? null : () => _sendTestNotification(l10n),
          ),
        ],
      ],
    );
  }

  String _notificationStatusText(AppLocalizations l10n) =>
      switch (_notificationsEnabled) {
        true => l10n.notificationsEnabled,
        false => l10n.notificationsDenied,
        null => l10n.notificationsNotChecked,
      };

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
