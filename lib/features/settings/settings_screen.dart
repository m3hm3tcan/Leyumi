import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../core/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/reset_service.dart';
import '../children/child_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
