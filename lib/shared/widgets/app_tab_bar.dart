import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// Horizontally-scrollable underline tab bar with an animated
/// indicator that slides + resizes between tabs.
///
/// Renders a row of text tabs. The active tab shows a bold label
/// (`primaryText`); inactive tabs use `secondaryText`. A single
/// `secondary`-colored underline sits under the row and animates
/// its left offset + width between tabs on selection change.
///
/// Always horizontally scrollable — degrades gracefully when the
/// number of tabs grows past what fits on-screen. For a fixed-width
/// distribution (equal tab widths) use a native Flutter TabBar; this
/// widget is for content-width tabs that expand naturally.
///
/// Fires a selection haptic on tap.
class AppTabBar extends StatefulWidget {
  const AppTabBar({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  /// One GlobalKey per tab, refreshed whenever the label count
  /// changes. Used to measure each tab's rendered width so the
  /// underline can compute its cumulative offset.
  final List<GlobalKey> _tabKeys = [];

  /// Rendered width of each tab, populated after first layout via
  /// [addPostFrameCallback]. Empty until measurement lands, in which
  /// case the underline is hidden for one frame.
  List<double> _widths = const [];

  static const _underlineHeight = 3.0;
  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant AppTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Label count changed → new keys + re-measure.
    if (oldWidget.labels.length != widget.labels.length ||
        !_labelsMatch(oldWidget.labels, widget.labels)) {
      _syncKeys();
      _scheduleMeasure();
    }
  }

  bool _labelsMatch(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _syncKeys() {
    _tabKeys
      ..clear()
      ..addAll(List.generate(widget.labels.length, (_) => GlobalKey()));
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final widths = <double>[];
      for (final key in _tabKeys) {
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        widths.add(box?.size.width ?? 0);
      }
      // Only trigger a rebuild if the measurements actually changed —
      // otherwise we'd loop.
      if (!_widthsEqual(widths, _widths)) {
        setState(() => _widths = widths);
      }
    });
  }

  bool _widthsEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.5) return false;
    }
    return true;
  }

  double _offsetForIndex(int i) {
    var offset = 0.0;
    for (var j = 0; j < i && j < _widths.length; j++) {
      offset += _widths[j];
    }
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final safeIndex = widget.currentIndex.clamp(0, widget.labels.length - 1);
    final measured = _widths.length == widget.labels.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.labels.length; i++)
                  _TabItem(
                    key: _tabKeys[i],
                    label: widget.labels[i],
                    active: i == safeIndex,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onTap(i);
                    },
                  ),
              ],
            ),
            // Animated indicator — hidden until the first measurement
            // pass so the widths are known. Then AnimatedPositioned
            // interpolates left + width between the previous and new
            // tab on every currentIndex change.
            if (measured)
              AnimatedPositioned(
                duration: _duration,
                curve: _curve,
                left: _offsetForIndex(safeIndex),
                bottom: 0,
                width: _widths[safeIndex],
                height: _underlineHeight,
                child: Container(color: colors.secondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        // Bottom padding leaves room for the underline (rendered by
        // the parent Stack) without stacking a border on the label.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Text(
          label,
          style: (active ? AppTypography.boldMedium : AppTypography.bodyMedium)
              .copyWith(color: active ? colors.primaryText : colors.secondaryText),
        ),
      ),
    );
  }
}
