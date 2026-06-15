import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/animations.dart';
import '../../labs/data/lab_models.dart';
import '../../labs/data/public_repository.dart';
import '../../workspace/application/workspace_provider.dart';

/// Patient home — a native landing screen that mirrors the web LandingPage:
/// a branded hero with search + browse chips, popular searches, featured labs,
/// a "why choose" feature grid and a "how it works" walkthrough.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _popularTerms = ['CBC', 'Lipid Profile', 'Thyroid Panel', 'HbA1c'];

  String _searchRoute({String? q, String? sort}) {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (sort != null) params['sort'] = sort;
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '/patient/search${qs.isEmpty ? '' : '?$qs'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(
          labsListProvider(const LabsFilter(sort: 'rating')),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Hero(searchRoute: _searchRoute),
            const SizedBox(height: 20),
            FadeSlideIn(index: 1, child: _PopularSearches(terms: _popularTerms, searchRoute: _searchRoute)),
            const SizedBox(height: 24),
            FadeSlideIn(index: 2, child: _FeaturedLabs(searchRoute: _searchRoute)),
            const SizedBox(height: 28),
            FadeSlideIn(index: 3, child: const _WhyChoose()),
            const SizedBox(height: 28),
            FadeSlideIn(index: 4, child: const _HowItWorks()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _Hero extends ConsumerWidget {
  const _Hero({required this.searchRoute});

  final String Function({String? q, String? sort}) searchRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Greet the user by first name when their profile has loaded.
    final fullName =
        ref.watch(workspaceProfileProvider).valueOrNull?.fullName.trim();
    final firstName =
        (fullName != null && fullName.isNotEmpty) ? fullName.split(' ').first : null;
    final greeting =
        firstName != null ? l10n.homeGreeting(firstName) : l10n.homeGreetingGuest;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brand, AppColors.brandStrong],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand + greeting row
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.science_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      greeting,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Trust badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      l10n.homeTrustBadge,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.homeHeadline,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 18),
              // Tappable search field → search screen
              _SearchField(onTap: () => context.push(searchRoute())),
              const SizedBox(height: 14),
              // Browse-by chips
              Row(
                children: [
                  _HeroChip(
                    icon: Icons.near_me_outlined,
                    label: l10n.nearest,
                    onTap: () => context.push(searchRoute(sort: 'distance')),
                  ),
                  const SizedBox(width: 8),
                  _HeroChip(
                    icon: Icons.payments_outlined,
                    label: l10n.bestPrice,
                    onTap: () => context.push(searchRoute(sort: 'price')),
                  ),
                  const SizedBox(width: 8),
                  _HeroChip(
                    icon: Icons.star_outline_rounded,
                    label: l10n.topRated,
                    onTap: () => context.push(searchRoute(sort: 'rating')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.brand, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.homeSearchHint,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 15),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Popular searches ────────────────────────────────────────────────────────

class _PopularSearches extends StatelessWidget {
  const _PopularSearches({required this.terms, required this.searchRoute});

  final List<String> terms;
  final String Function({String? q, String? sort}) searchRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.popular,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final term in terms)
                ActionChip(
                  label: Text(term),
                  onPressed: () => context.push(searchRoute(q: term)),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  backgroundColor: theme.colorScheme.surface,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Featured labs ───────────────────────────────────────────────────────────

class _FeaturedLabs extends ConsumerWidget {
  const _FeaturedLabs({required this.searchRoute});

  final String Function({String? q, String? sort}) searchRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labsAsync =
        ref.watch(labsListProvider(const LabsFilter(sort: 'rating')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.featuredLabs,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.featuredLabsSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push(searchRoute()),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: labsAsync.when(
            loading: () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(
                3,
                (_) => Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  child: const ShimmerBox(height: 196, width: 250),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              if (data.items.isEmpty) return const SizedBox.shrink();
              final labs = data.items.take(6).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: labs.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _FeaturedLabCard(lab: labs[i], featured: i == 0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedLabCard extends StatelessWidget {
  const _FeaturedLabCard({required this.lab, this.featured = false});

  final PublicLabCard lab;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: PressableCard(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/patient/labs/${lab.id}', extra: lab),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(lab.imageEmoji ?? '🔬',
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const Spacer(),
                    if (featured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_outlined,
                                size: 13, color: Color(0xFFB45309)),
                            const SizedBox(width: 3),
                            Text(
                              l10n.topRated,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lab.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 3),
                    Text(
                      lab.rating?.toStringAsFixed(1) ?? '—',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${lab.reviews})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.labCount(lab.testsAvailable),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lab.startingFromEgp != null)
                            Text(
                              l10n.startingFromEgp(lab.startingFromEgp!),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.brand,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        l10n.book,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Why choose TesTly ───────────────────────────────────────────────────────

class _WhyChoose extends StatelessWidget {
  const _WhyChoose();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final features = [
      (
        Icons.compare_arrows,
        l10n.featureComparePricesTitle,
        l10n.featureComparePricesDesc
      ),
      (Icons.verified_outlined, l10n.featureReviewsTitle, l10n.featureReviewsDesc),
      (
        Icons.home_outlined,
        l10n.featureHomeCollectionTitle,
        l10n.featureHomeCollectionDesc
      ),
      (
        Icons.description_outlined,
        l10n.featureDigitalResultsTitle,
        l10n.featureDigitalResultsDesc
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whyChooseTestly,
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final f in features)
                    SizedBox(
                      width: cardWidth,
                      child: _FeatureCard(
                          icon: f.$1, title: f.$2, description: f.$3),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.brand, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── How it works ────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = [
      ('1', l10n.stepSearchTitle, l10n.stepSearchDesc),
      ('2', l10n.stepCompareTitle, l10n.stepCompareDesc),
      ('3', l10n.stepBookTitle, l10n.stepBookDesc),
      ('4', l10n.stepResultsTitle, l10n.stepResultsDesc),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howItWorks,
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++) ...[
            _StepRow(
              number: steps[i].$1,
              title: steps[i].$2,
              description: steps[i].$3,
              isLast: i == steps.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.description,
    required this.isLast,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
