import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_sheet_shell.dart';

/// Opens a bottom sheet with a Cupertino-style wheel picker and returns
/// the selected item (or null if the user cancels).
///
/// Use for value pickers where the choices are numeric or short strings
/// (height, weight, position). For dates, use [showAppDatePicker].
/// For longer text lists or actions, use `showAppSheet` with tappable
/// rows instead.
///
/// Example:
///   final ft = await showAppWheelPicker&lt;int&gt;(
///     context: context,
///     items: [3, 4, 5, 6, 7],
///     itemLabel: (v) =&gt; '$v ft',
///     initialItem: 5,
///   );
Future<T?> showAppWheelPicker<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T item) itemLabel,
  T? initialItem,
  String? title,
}) {
  final initialIndex = initialItem == null ? 0 : items.indexOf(initialItem);
  final startIndex = initialIndex >= 0 ? initialIndex : 0;

  return showAppSheet<T>(
    context: context,
    builder: (sheetContext) {
      int selectedIndex = startIndex;
      final colors = sheetContext.colors;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PickerBar(
            title: title,
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
      );
    },
  );
}

/// Opens a bottom sheet with a native Cupertino date picker (month, day,
/// year wheels combined) and returns the selected date (or null on cancel).
///
/// Prefer this over three separate wheel pickers — one interaction sets
/// the whole date and honors month-length constraints automatically.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String? title,
}) {
  return showAppSheet<DateTime>(
    context: context,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      DateTime selected = initialDate ?? DateTime.now();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PickerBar(
            title: title,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(selected),
          ),
          SizedBox(
            height: 220,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                  dateTimePickerTextStyle: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selected,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (date) {
                  selected = date;
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _PickerBar extends StatelessWidget {
  const _PickerBar({required this.onCancel, required this.onDone, this.title});

  final VoidCallback onCancel;
  final VoidCallback onDone;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.alternate, width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (title != null)
            Text(
              title!,
              style: AppTypography.titleSmall.copyWith(color: colors.primaryText),
            ),
          Row(
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
        ],
      ),
    );
  }
}
