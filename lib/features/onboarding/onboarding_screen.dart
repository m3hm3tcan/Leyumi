import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/baby_profile.dart';
import '../children/widgets/child_profile_form.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish(BabyProfile profile) async {
    await context.read<ActiveChildProvider>().saveChild(profile);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const PageScrollPhysics(),
                onPageChanged: (value) => setState(() => _page = value),
                children: [
                  _IntroPage(
                    icon: Icons.favorite_rounded,
                    colors: const [Color(0xff6D63E8), Color(0xffAA67D8)],
                    title: l10n.welcomeToLeyumi,
                    description: l10n.onboardingWelcomeDescription,
                  ),
                  _IntroPage(
                    icon: Icons.auto_graph_rounded,
                    colors: const [Color(0xff4D8BE8), Color(0xff63C7D8)],
                    title: l10n.onboardingTrackTitle,
                    description: l10n.onboardingTrackDescription,
                  ),
                  _PlanPage(l10n: l10n),
                  _IntroPage(
                    icon: Icons.shield_rounded,
                    colors: const [Color(0xff39A58D), Color(0xff76C98E)],
                    title: l10n.onboardingPrivacyTitle,
                    description: l10n.onboardingPrivacyDescription,
                  ),
                  _ProfilePage(onSaved: _finish),
                ],
              ),
            ),
            if (_page < 4)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: index == _page ? 24 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: index == _page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.continueLabel),
                      ),
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

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.colors,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.first.withAlpha(65),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 68),
          ),
          const SizedBox(height: 42),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha(170),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanPage extends StatelessWidget {
  const _PlanPage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 62,
            color: Color(0xff725DE2),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.onboardingFreePremiumTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          _PlanCard(
            title: l10n.freePlan,
            features: l10n.freePlanFeatures,
            color: const Color(0xff4C9B8B),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: l10n.premiumPlan,
            features: l10n.premiumPlanFeatures,
            color: const Color(0xff725DE2),
            premium: true,
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.features,
    required this.color,
    this.premium = false,
  });

  final String title;
  final String features;
  final Color color;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                premium
                    ? Icons.workspace_premium_rounded
                    : Icons.check_circle_rounded,
                color: color,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final feature in features.split('\n'))
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.onSaved});

  final ValueChanged<BabyProfile> onSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        children: [
          Text(
            l10n.createFirstChildProfile,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingChildDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha(165),
            ),
          ),
          const SizedBox(height: 24),
          ChildProfileForm(submitLabel: l10n.getStarted, onSaved: onSaved),
        ],
      ),
    );
  }
}
