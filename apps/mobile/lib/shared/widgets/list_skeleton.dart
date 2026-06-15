import 'package:flutter/material.dart';
import 'animations.dart';

/// A shimmering placeholder list shown while card data loads.
///
/// Mirrors the silhouette of the real cards (avatar tile + two lines + chip
/// row) so the transition to loaded content feels seamless rather than a
/// jarring spinner→content swap.
class CardListSkeleton extends StatelessWidget {
  const CardListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        offset: 10,
        child: const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 170, height: 14),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 110, height: 11),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ShimmerBox(
                        width: 64,
                        height: 20,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 8),
                      ShimmerBox(
                        width: 80,
                        height: 20,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
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
