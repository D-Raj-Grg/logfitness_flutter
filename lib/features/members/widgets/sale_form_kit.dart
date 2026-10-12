// Building blocks for the long desk forms: register a member, renew a
// membership, take a payment, edit a member.
//
// One hierarchy for all of them, so a cashier who has learnt one has learnt
// four: a titled section (one idea per section, generous space between
// sections, tight space between its fields), problems in a tinted block of
// their own, the sale's full breakdown as an ordinary Summary section at the
// end of the scrolling form, and only a slim one-row bar (key figure plus the
// one primary action) docked to the bottom edge.
//
// Presentation only. Nothing here knows about validation, providers or RPCs.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

/// A titled group of fields. Space does the grouping: no card, no divider.
class FormSection extends StatelessWidget {
  const FormSection({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: Brand.spaceXs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: Brand.spaceMd),
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: Brand.spaceMd),
          children[i],
        ],
      ],
    );
  }
}

/// The gap between two [FormSection]s.
const SizedBox sectionGap = SizedBox(height: Brand.spaceXl);

/// Two fields side by side when there is room, stacked when there is not
/// (narrow phones, large text).
class FieldPair extends StatelessWidget {
  const FieldPair({required this.first, required this.second, super.key});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final bool stack =
            box.maxWidth < 380 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              first,
              const SizedBox(height: Brand.spaceMd),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: first),
            const SizedBox(width: Brand.spaceMd),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

/// A problem, in a block of its own. [onRetry] only for failures that can
/// succeed second time; a refusal repeats identically.
class FormProblem extends StatelessWidget {
  const FormProblem({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.error_outline, size: 20, color: scheme.error),
              const SizedBox(width: Brand.spaceSm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
          if (onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
        ],
      ),
    );
  }
}

/// A neutral explanation where a field would be: nothing wrong, nothing to
/// choose.
class FormNote extends StatelessWidget {
  const FormNote(this.message, {this.icon = Icons.info_outline, super.key});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: Brand.spaceSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A date input: the whole field opens the picker, a clear button removes it.
class PlainDateField extends StatelessWidget {
  const PlainDateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.helper,
    this.emptyText = 'Not set',
    this.allowFuture = false,
    this.yearsBack = 100,
    this.initialYearsBack = 0,
    this.pickKey,
    super.key,
  });

  final String label;
  final String? helper;
  final String emptyText;
  final DateTime? value;
  final bool allowFuture;
  final int yearsBack;

  /// Where the picker opens when nothing is chosen yet (a date of birth opens
  /// a quarter century back, not on today).
  final int initialYearsBack;
  final Key? pickKey;
  final ValueChanged<DateTime?> onPick;

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          value ?? DateTime(now.year - initialYearsBack, now.month, now.day),
      firstDate: DateTime(now.year - yearsBack),
      lastDate: allowFuture ? DateTime(now.year + 2) : now,
    );
    if (picked != null) {
      // Pinned to UTC midnight so no offset can move the day.
      onPick(DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      key: pickKey,
      borderRadius: BorderRadius.circular(Brand.radiusMedium),
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear',
                  onPressed: () => onPick(null),
                ),
        ),
        child: Text(
          value == null ? emptyText : formatPlainDate(value!),
          style: value == null
              ? theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// One line of the sale's breakdown.
class SummaryLine {
  const SummaryLine(this.label, this.paisa, {this.negative = false});

  final String label;
  final int paisa;

  /// Shown as a deduction ("-NPR 500"), for discounts and waivers.
  final bool negative;
}

/// What a sale adds up to. One value feeds both the slim [SaleSummaryBar]
/// (the key figure, always on screen) and the [SaleSummarySection] (the whole
/// breakdown, in the scrolling form), so the two can never disagree.
class SaleFigures {
  const SaleFigures({
    this.headline,
    this.detail,
    this.lines = const <SummaryLine>[],
    this.totalPaisa,
    this.paidPaisa,
    this.duePaisa,
    this.emptyHint,
    this.totalLabel = 'Total',
    this.paidLabel = 'Paid now',
    this.dueLabel = 'Due',
  });

  /// The plan or invoice being sold, e.g. "Gym Only".
  final String? headline;

  /// The line under the headline, e.g. the period the sale covers.
  final String? detail;
  final List<SummaryLine> lines;

  /// Null means no sale yet: [emptyHint] is shown instead of figures.
  final int? totalPaisa;
  final int? paidPaisa;
  final int? duePaisa;
  final String? emptyHint;
  final String totalLabel;
  final String paidLabel;
  final String dueLabel;

  bool get hasFigures => totalPaisa != null;
}

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// The one primary action, docked to the bottom edge, with the sale's key
/// figure beside it.
///
/// Deliberately slim: a single row, never a card. The full breakdown lives in
/// [SaleSummarySection], in the scrolling form. While the on-screen keyboard
/// is up the figure drops away and the button alone remains, so the field
/// being typed in keeps its room.
class SaleSummaryBar extends StatelessWidget {
  const SaleSummaryBar({
    required this.submitKey,
    required this.submitLabel,
    required this.onSubmit,
    this.busy = false,
    this.figures,
    this.destructive = false,
    super.key,
  });

  /// Everything the bar measures: its content plus the safe area. The widget
  /// tests hold it to a ceiling so it cannot grow back into a card.
  static const Key dockedBarKey = ValueKey<String>('docked-bar');

  final Key submitKey;
  final String submitLabel;
  final VoidCallback onSubmit;
  final bool busy;

  /// Null for a form with nothing to total (editing a member).
  final SaleFigures? figures;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MediaQueryData media = MediaQuery.of(context);
    // Read off the view, not MediaQuery: a Scaffold strips the keyboard inset
    // from its body's MediaQuery, and two of these bars live in a body.
    final bool typing = View.of(context).viewInsets.bottom > 0;
    final SaleFigures? f = figures;

    final Widget button = FilledButton(
      key: submitKey,
      onPressed: busy ? null : onSubmit,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceMd,
          vertical: Brand.spaceSm,
        ),
        backgroundColor: destructive ? scheme.error : null,
        foregroundColor: destructive ? scheme.onError : null,
      ),
      // A long label shrinks rather than wrapping: the bar is one row.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(busy ? 'Saving…' : submitLabel, maxLines: 1),
      ),
    );

    return Material(
      key: dockedBarKey,
      color: scheme.surfaceContainer,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        // The home indicator only needs clearing, not a full safe-area
        // gutter: taking all of it would cost a notched phone ~20dp more.
        padding: EdgeInsets.fromLTRB(
          Brand.spaceMd,
          Brand.spaceSm,
          Brand.spaceMd,
          math.max(Brand.spaceSm, media.padding.bottom - Brand.spaceSm),
        ),
        // The bar is chrome, not content: past 1.2x it would stop being one
        // row. The figures stay fully scaled in the Summary section.
        child: MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(maxScaleFactor: 1.2),
          ),
          child: typing || f == null
              ? SizedBox(width: double.infinity, child: button)
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    return Row(
                      children: <Widget>[
                        Expanded(child: _KeyFigure(figures: f)),
                        const SizedBox(width: Brand.spaceMd),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: box.maxWidth * 0.68,
                          ),
                          child: button,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// "Due NPR 3,400", or once nothing is owed "Total NPR 6,000 · Due NPR 0".
class _KeyFigure extends StatelessWidget {
  const _KeyFigure({required this.figures});

  final SaleFigures figures;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    if (!figures.hasFigures) {
      return Text(
        figures.emptyHint ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    final int due = figures.duePaisa ?? 0;
    final TextStyle? strong = theme.textTheme.titleSmall?.copyWith(
      // Money still owed is the one figure the desk must not miss.
      color: due > 0 ? scheme.error : null,
      fontFeatures: _tabular,
    );
    final TextStyle? muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      fontFeatures: _tabular,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            if (due == 0)
              TextSpan(
                text:
                    '${figures.totalLabel} '
                    '${formatMoney(figures.totalPaisa!)} · ',
                style: muted,
              ),
            TextSpan(
              text: '${figures.dueLabel} ${formatMoney(due)}',
              style: strong,
            ),
          ],
        ),
        maxLines: 1,
      ),
    );
  }
}

/// The whole sale, line by line: plan price, fees, waivers, discounts, then
/// what is owed, what is being taken and what is left. A normal section of the
/// scrolling form, placed just above its end.
class SaleSummarySection extends StatelessWidget {
  const SaleSummarySection({
    required this.figures,
    this.title = 'Summary',
    super.key,
  });

  final SaleFigures figures;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SaleFigures f = figures;
    if (!f.hasFigures && f.emptyHint == null) {
      return const SizedBox.shrink();
    }
    final int due = f.duePaisa ?? 0;
    return FormSection(
      title: title,
      children: <Widget>[
        if (!f.hasFigures)
          FormNote(f.emptyHint!)
        else ...<Widget>[
          if (f.headline != null || f.detail != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (f.headline != null)
                  Text(f.headline!, style: theme.textTheme.titleSmall),
                if (f.detail != null)
                  Text(
                    f.detail!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          Column(
            children: <Widget>[
              for (final SummaryLine line in f.lines)
                _FigureRow(
                  label: line.label,
                  value:
                      '${line.negative ? '-' : ''}${formatMoney(line.paisa)}',
                ),
              if (f.lines.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Brand.spaceSm),
                  child: Divider(height: 1),
                ),
              _FigureRow(
                label: f.totalLabel,
                value: formatMoney(f.totalPaisa!),
                strong: true,
              ),
              _FigureRow(
                label: f.paidLabel,
                value: formatMoney(f.paidPaisa ?? 0),
              ),
              _FigureRow(
                label: f.dueLabel,
                value: formatMoney(due),
                strong: true,
                // Money still owed is the one figure the desk must not miss.
                color: due > 0 ? scheme.error : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FigureRow extends StatelessWidget {
  const _FigureRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.color,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? base = strong
        ? theme.textTheme.titleSmall
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: base?.copyWith(
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Brand.spaceSm),
          Text(
            value,
            style: base?.copyWith(color: color, fontFeatures: _tabular),
          ),
        ],
      ),
    );
  }
}
