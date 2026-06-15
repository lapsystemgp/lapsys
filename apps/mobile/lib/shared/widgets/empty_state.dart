import 'package:flutter/material.dart';
import 'animations.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  // Slow, continuous bob so the empty state feels alive rather than dead-stopped.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduce = AppMotion.reduceMotion(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeSlideIn(
          duration: AppMotion.slow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon sits inside a soft tonal disc, gently floating.
              AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, reduce ? 0 : -4 * _float.value),
                  child: child,
                ),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHighest,
                  ),
                  child: Icon(widget.icon, size: 52, color: scheme.outline),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
