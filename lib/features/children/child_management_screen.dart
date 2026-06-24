import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../l10n/app_localizations.dart';
import 'child_profile_screen.dart';

class ChildManagementScreen extends StatelessWidget {
  const ChildManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final children = context.watch<ActiveChildProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.childProfiles)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addChild(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addChildProfile),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: children.profiles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final profile = children.profiles[index];
          final selected = profile.id == children.activeChildId;
          return Card(
            child: ListTile(
              onTap: () async {
                await children.selectChild(profile.id);
                if (context.mounted) Navigator.pop(context);
              },
              leading: CircleAvatar(
                child: Icon(
                  profile.gender.toLowerCase() == 'male'
                      ? Icons.boy_rounded
                      : Icons.girl_rounded,
                ),
              ),
              title: Text(
                profile.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                MaterialLocalizations.of(
                  context,
                ).formatMediumDate(profile.birthDate),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected)
                    const Icon(Icons.check_circle, color: Colors.green),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfileScreen(profile: profile),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addChild(BuildContext context) {
    final childProvider = context.read<ActiveChildProvider>();
    final premium = context.read<PremiumProvider>();
    if (childProvider.profiles.isNotEmpty &&
        !premium.hasAccess(PremiumFeature.multipleChildren)) {
      PremiumAccess.open(
        context,
        feature: PremiumFeature.multipleChildren,
        builder: (_) => const ChildProfileScreen(),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileScreen()),
    );
  }
}
