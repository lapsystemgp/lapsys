import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/lab_models.dart';
import '../data/public_repository.dart';
import '../../booking/data/booking_models.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

class LabDetailScreen extends ConsumerWidget {
  final String labId;

  const LabDetailScreen({super.key, required this.labId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(labDetailProvider(labId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labDetailProvider(labId)),
        ),
      ),
      data: (detail) => _LabDetailView(detail: detail),
    );
  }
}

class _LabDetailView extends StatefulWidget {
  final PublicLabDetailResponse detail;

  const _LabDetailView({required this.detail});

  @override
  State<_LabDetailView> createState() => _LabDetailViewState();
}

class _LabDetailViewState extends State<_LabDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lab = widget.detail.lab;
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(lab.name),
              background: Container(
                color: theme.colorScheme.primaryContainer,
                child: Center(
                  child: Text(
                    lab.imageEmoji ?? '🔬',
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(lab.address,
                            style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (lab.rating != null)
                        Chip(
                          avatar: const Icon(Icons.star, size: 16),
                          label: Text(
                              '${lab.rating!.toStringAsFixed(1)} · ${lab.reviews} reviews'),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (lab.accreditation != null)
                        Chip(
                          avatar: const Icon(Icons.verified, size: 16),
                          label: Text(lab.accreditation!),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (lab.homeCollection)
                        Chip(
                          avatar: const Icon(Icons.home, size: 16),
                          label: Text(l10n.homeCollection),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabs,
                tabs: [
                  Tab(text: l10n.testsTab),
                  Tab(text: l10n.labTabReviews),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _TestsTab(
              tests: widget.detail.tests,
              lab: lab,
            ),
            _ReviewsTab(reviews: widget.detail.reviewItems),
          ],
        ),
      ),
    );
  }
}

class _TestsTab extends StatelessWidget {
  final List<PublicLabTest> tests;
  final PublicLabCard lab;

  const _TestsTab({required this.tests, required this.lab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (tests.isEmpty) {
      return EmptyState(
        icon: Icons.science_outlined,
        message: l10n.noTestsAvailable,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tests.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => _TestTile(test: tests[i], lab: lab),
    );
  }
}

class _TestTile extends StatelessWidget {
  final PublicLabTest test;
  final PublicLabCard lab;

  const _TestTile({required this.test, required this.lab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      title: Text(test.name, style: theme.textTheme.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(test.category,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary)),
          if (test.description != null) ...[
            const SizedBox(height: 2),
            Text(test.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          if (test.turnaroundTime != null)
            Text(l10n.resultsIn(test.turnaroundTime!),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${test.priceEgp} EGP',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => context.push(
              '/patient/book',
              extra: BookingFlowParams(
                labId: lab.id,
                testId: test.id,
                labName: lab.name,
                testName: test.name,
                priceEgp: test.priceEgp,
                supportsHomeCollection: lab.homeCollection,
                supportsHomeTestKit: lab.homeTestKit,
                preparation: test.preparation,
              ),
            ),
            child: Text(l10n.book),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<PublicReview> reviews;

  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (reviews.isEmpty) {
      return EmptyState(
        icon: Icons.rate_review_outlined,
        message: l10n.noReviewsYet,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => _ReviewTile(review: reviews[i]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final PublicReview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.patientName,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 4),
            Text(review.comment!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
