import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../application/lab_workspace_provider.dart';
import '../../patient/labs/data/public_repository.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final labInfoAsync = ref.watch(labInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labTabReviews)),
      body: labInfoAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labWorkspaceProvider),
        ),
        data: (labInfo) => _ReviewsBody(labId: labInfo.id),
      ),
    );
  }
}

class _ReviewsBody extends ConsumerWidget {
  const _ReviewsBody({required this.labId});
  final String labId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(labDetailProvider(labId));

    return detailAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(labDetailProvider(labId)),
      ),
      data: (detail) {
        final reviews = detail.reviewItems;
        final lab = detail.lab;

        if (reviews.isEmpty) {
          return EmptyState(
            icon: Icons.star_outline,
            message: l10n.noReviewsYet,
            subtitle: l10n.reviewsWillAppear,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(labDetailProvider(labId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Rating summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            lab.rating?.toStringAsFixed(1) ?? '—',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          _StarRow(rating: lab.rating ?? 0),
                          const SizedBox(height: 4),
                          Text('${lab.reviews} reviews',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lab.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(lab.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reviews list
              ...reviews.map((review) => _ReviewCard(review: review)),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final dynamic review;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(review.createdAt as String);
    final dateStr = createdAt != null
        ? DateFormat('dd MMM yyyy').format(createdAt.toLocal())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.patientName as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
            const SizedBox(height: 4),
            _StarRow(rating: (review.rating as int).toDouble()),
            if ((review.comment as String?) != null &&
                (review.comment as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment as String),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return Icon(Icons.star_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16);
        }
      }),
    );
  }
}
