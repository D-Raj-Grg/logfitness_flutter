// A form field that picks one value from a list, in a bottom sheet.
//
// WHY NOT `DropdownButtonFormField`
//
// Material's dropdown renders its menu as an overlay anchored to the field,
// and on a phone with more than a handful of options that overlay covers most
// of the form with an edge-to-edge, unlabelled list -- no title saying what is
// being chosen, no mark on the current value, and a tap target the width of
// the screen. The register form had three of them stacked, and the payment
// method one in particular (six rails) filled the lower two thirds of the
// screen with bare words.
//
// A modal sheet is the platform's own answer for this: it says what it is
// asking, it marks the current value, it has room for the second line a plan
// or a payment status needs, and it is reachable one-handed at the bottom of
// the screen rather than wherever the field happened to sit.
//
// It stays a [FormField], so `Form.validate()` and the validator still work
// exactly as they did for the dropdown it replaces.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

/// One choice in a [PickerField].
@immutable
class PickerOption<T> {
  const PickerOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;

  /// The line the field shows once this is chosen.
  final String label;

  /// The second line in the sheet -- a plan's term and price, a payment
  /// status's consequence. Never needed to identify the option, because the
  /// field itself only has room for [label].
  final String? subtitle;

  final IconData? icon;
}

/// Picks one of [options], showing [label] as the field's label.
class PickerField<T> extends FormField<T> {
  PickerField({
    required List<PickerOption<T>> options,
    required String label,
    required ValueChanged<T?> onChanged,
    T? value,
    String? hint,
    String? helperText,
    String? sheetTitle,
    super.enabled = true,
    super.key,
    super.validator,
    super.restorationId,
  }) : super(
         initialValue: value,
         builder: (FormFieldState<T> field) {
           final BuildContext context = field.context;
           final ThemeData theme = Theme.of(context);
           final PickerOption<T>? selected = _selectedOf(options, field.value);
           // Through the widget, not the constructor argument: `enabled` is a
           // super parameter, so it is not in scope inside this closure.
           final bool enabled = field.widget.enabled;

           return InkWell(
             borderRadius: BorderRadius.circular(12),
             onTap: !enabled
                 ? null
                 : () async {
                     // The keyboard belongs to whatever field was being typed
                     // in; leaving it up shoves the sheet into a third of the
                     // screen.
                     FocusScope.of(context).unfocus();
                     final T? picked = await _showPickerSheet<T>(
                       context: context,
                       title: sheetTitle ?? label,
                       options: options,
                       current: field.value,
                     );
                     if (picked == null) return;
                     field.didChange(picked);
                     onChanged(picked);
                   },
             child: InputDecorator(
               decoration: InputDecoration(
                 labelText: label,
                 helperText: helperText,
                 errorText: field.errorText,
                 enabled: enabled,
                 suffixIcon: const Icon(Icons.arrow_drop_down),
               ),
               isEmpty: selected == null,
               child: selected == null
                   ? (hint == null
                         ? null
                         : Text(
                             hint,
                             style: theme.textTheme.bodyLarge?.copyWith(
                               color: theme.colorScheme.onSurfaceVariant,
                             ),
                           ))
                   : Row(
                       children: <Widget>[
                         if (selected.icon != null) ...<Widget>[
                           Icon(selected.icon, size: 20),
                           const SizedBox(width: Brand.spaceSm),
                         ],
                         Expanded(
                           child: Text(
                             selected.label,
                             overflow: TextOverflow.ellipsis,
                             style: theme.textTheme.bodyLarge,
                           ),
                         ),
                       ],
                     ),
             ),
           );
         },
       );

  /// `firstWhereOrNull` without the collection dependency, and null-safe on a
  /// value that is not in the list -- which happens when the options change
  /// underneath a selection (a branch switch reloading the plan catalogue).
  static PickerOption<T>? _selectedOf<T>(
    List<PickerOption<T>> options,
    T? value,
  ) {
    if (value == null) return null;
    for (final PickerOption<T> option in options) {
      if (option.value == value) return option;
    }
    return null;
  }
}

/// The sheet itself. Returns null when dismissed without choosing, which is
/// why a dismissal never clears an existing selection.
Future<T?> _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<PickerOption<T>> options,
  required T? current,
}) {
  final ThemeData theme = Theme.of(context);

  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    // A long catalogue scrolls inside the sheet instead of running off the
    // bottom of the screen.
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Brand.spaceLg,
                0,
                Brand.spaceLg,
                Brand.spaceSm,
              ),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final PickerOption<T> option in options)
                    ListTile(
                      key: ValueKey<Object?>(option.value),
                      leading: option.icon == null
                          ? null
                          : Icon(option.icon),
                      title: Text(option.label),
                      subtitle: option.subtitle == null
                          ? null
                          : Text(option.subtitle!),
                      trailing: option.value == current
                          ? Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      selected: option.value == current,
                      onTap: () =>
                          Navigator.of(sheetContext).pop(option.value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
          ],
        ),
      ),
    ),
  );
}
