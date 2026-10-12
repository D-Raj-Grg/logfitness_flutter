// What the masthead of an invoice will look like, drawn from the form's
// current values. Mirrors `components/print/letterhead.tsx` upstream: the
// registered name when there is one, then address / phone / email, then
// PAN / VAT, with the logo on the left.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

class LetterheadPreview extends StatelessWidget {
  const LetterheadPreview({
    required this.name,
    this.legalName,
    this.address,
    this.phone,
    this.email,
    this.panNo,
    this.taxNote,
    this.invoiceTerms,
    this.logo,
    super.key,
  });

  final String name;
  final String? legalName;
  final String? address;
  final String? phone;
  final String? email;
  final String? panNo;
  final String? taxNote;
  final String? invoiceTerms;

  /// An already-resolved image: a network image for the saved logo, a memory
  /// image for one just picked.
  final ImageProvider? logo;

  static String? _clean(String? v) {
    final String? t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String heading = _clean(legalName) ?? _clean(name) ?? 'Your gym';
    final List<String> contact = <String?>[
      _clean(address),
      _clean(phone),
      _clean(email),
    ].whereType<String>().toList(growable: false);
    final String? pan = _clean(panNo);
    final String? tax = _clean(taxNote);
    final String? terms = _clean(invoiceTerms);
    final TextStyle? small = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Container(
      key: const ValueKey<String>('letterhead-preview'),
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        // A sheet of paper: stays light in dark mode, like the printout.
        color: Colors.white,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black87),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (logo != null) ...<Widget>[
                  Image(image: logo!, height: 48, fit: BoxFit.contain),
                  const SizedBox(width: Brand.spaceMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        heading,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      for (final String line in contact)
                        Text(
                          line,
                          style: small?.copyWith(color: Colors.black54),
                        ),
                      if (pan != null)
                        Text(
                          'PAN / VAT: $pan',
                          style: small?.copyWith(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
                Text(
                  'INVOICE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const Divider(height: Brand.spaceLg),
            Text(
              'Invoice lines appear here',
              style: small?.copyWith(color: Colors.black38),
            ),
            if (tax != null || terms != null) ...<Widget>[
              const Divider(height: Brand.spaceLg),
              if (tax != null)
                Text(tax, style: small?.copyWith(color: Colors.black54)),
              if (terms != null)
                Text(terms, style: small?.copyWith(color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }
}
