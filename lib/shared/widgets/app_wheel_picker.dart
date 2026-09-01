import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// Opens a bottom sheet with a Cupertino-style wheel picker and returns
/// the selected item (or null if the user cancels).
///
/// Use for value pickers where the choices are numeric or short strings
/// (height, weight, month/day/year). For longer text lists or actions,
/// use `showAppSheet` with tappable rows instead.
///
/// Example:
///   final ft = await showAppWheelPicker&lt;int&gt;(
///     context: context,
///     items: [3, 4, 5, 6, 7],
///     itemLabel: (v) => '$v ft',
///     initialItem: 5,
///   );
Future<T?> showAppWheelPicker<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T item) itemLabel,
  T? initialItem,
}) {
  final initialIndex = initialItem == null ? 0 : items.indexOf(initialItem);
  final startIndex = initialIndex >= 0 ? initialIndex : 0;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      int selectedIndex = startIndex;

      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.primaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WheelPickerBar(
                onCancel: () => Navigator.of(sheetContext).pop(),
                onDone: () => Navigator.of(sheetContext).pop(items[selectedIndex]),
              ),
              SizedBox(
                height: 220,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                    ),
                  ),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: startIndex),
                    itemExtent: 40,
                    onSelectedItemChanged: (i) {
                      selectedIndex = i;
                      HapticFeedback.selectionClick();
                    },
                    children: [
                      for (final item in items)
                        Center(
                          child: Text(
                            itemLabel(item),
                            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _WheelPickerBar extends StatelessWidget {
  const _WheelPickerBar({required this.onCancel, required this.onDone});

  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.alternate, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              onCancel();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Cancel',
                style: AppTypography.bodyLarge.copyWith(color: colors.secondaryText),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
              onDone();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Done',
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.link,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
