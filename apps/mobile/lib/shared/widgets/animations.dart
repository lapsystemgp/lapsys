import 'package:flutter/material.dart';

/// Motion toolkit for TesTly.
///
/// A small, dependency-free set of building blocks that add polish without
/// touching the design system or palette. Every animation here is purely
/// transform/opacity based so it stays cheap on low-end devices and honours
/// the platform "reduce motion" accessibility setting.
///
/// Shared timing language so motion feels like one system, not scattered
/// one-offs.
abstract final class AppMotion {
  /// The signature easing — a gentle, slightly overshooting decelerate that
  /// reads as "settling into place".
  static const curve = Curves.easeOutCubic;
  static const curveEmphasized = Curves.easeOutBack;

  static const fast = Duration(milliseconds: 220);
  static const normal = Duration(milliseconds: 380);
  static const slow = Duration(milliseconds: 560);

  /// Per-item delay used when staggering a list/grid entrance.
  static const stagger = Duration(milliseconds: 55);

  /// Whether the OS asked us to minimise motion. When true, callers should
  /// skip transl/scale animation and just snap to the final state.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Fades + slides a child up into place on first build.
///
/// Drop it around any widget for a tasteful entrance. Provide [index] when
/// used inside a list so siblings cascade in (`delay = index * stagger`).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.duration = AppMotion.normal,
    this.offset = 22,
    this.curve = AppMotion.curve,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  /// How far (in logical px) the child travels upward as it fades in.
  final double offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppMotion.reduceMotion(context)) {
        _c.value = 1; // snap to final state
        return;
      }
      final total = widget.delay + AppMotion.stagger * widget.index;
      Future<void>.delayed(total, () {
        if (mounted) _c.forward();
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: widget.curve);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Wraps a tappable surface so it springs slightly inward while pressed,
/// giving cards and tiles a tactile, physical feel.
///
/// Use instead of a bare [InkWell] when you want the *whole card* to respond
/// to touch. The ripple still works because we keep an inner [InkWell].
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      child: InkWell(
        borderRadius: radius,
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: widget.child,
      ),
    );
  }
}

/// Tweens an integer (or formatted) value from 0 → [value] on build / change.
///
/// Great for dashboard stat counters. Pass [formatter] to wrap the running
/// number (e.g. `'EGP $v'`).
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = AppMotion.slow,
    this.formatter,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final String Function(int value)? formatter;

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: reduce ? Duration.zero : duration,
      curve: AppMotion.curve,
      builder: (context, v, _) => Text(
        formatter?.call(v) ?? '$v',
        style: style,
      ),
    );
  }
}

/// A horizontal progress bar that animates from 0 → [value] (0..1) and stays
/// in sync if the value later changes.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    this.color,
    this.duration = AppMotion.slow,
  });

  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(minHeight / 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: reduce ? Duration.zero : duration,
        curve: AppMotion.curve,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: minHeight,
          backgroundColor: backgroundColor,
          color: color,
        ),
      ),
    );
  }
}

/// A shimmering placeholder block used to build skeleton loaders.
///
/// Colours are derived from the active [ColorScheme] so it adapts to light /
/// dark without hardcoding anything.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.onSurface.withAlpha(12),
      base,
    );
    final radius = widget.borderRadius ?? BorderRadius.circular(8);

    if (AppMotion.reduceMotion(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: base, borderRadius: radius),
      );
    }

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Sweep a soft highlight band left→right across the block.
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 - 2 * (1 - t), 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}
