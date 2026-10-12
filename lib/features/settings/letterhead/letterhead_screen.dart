// Settings -> Letterhead & invoice (owner only).
//
// Port of `logfitness_saas/components/settings/org-letterhead-form.tsx`: the
// gym's registered name, address, contact, PAN/VAT, terms and logo -- what every
// printed invoice and receipt says about the gym -- with a live preview.
//
// Validation is pure (`lib/domain/validation/org_letterhead.dart`); the write
// is `LetterheadSaveController`. Role gating is UX only: `orgs` UPDATE and the
// logo bucket are owner-only in RLS, and a refusal reaches the screen as a
// sentence, never a silent "saved".
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/orgs/org_profile.dart';
import 'package:logfitness_flutter/data/orgs/orgs_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/validation/org_letterhead.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/letterhead/letterhead_preview.dart';
import 'package:logfitness_flutter/features/settings/letterhead/letterhead_providers.dart';

String _logoContentType(String path) {
  final String lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

class LetterheadScreen extends ConsumerWidget {
  const LetterheadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OrgProfile?> profile = ref.watch(orgProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Letterhead & invoice')),
      body: AsyncValueView<OrgProfile?>(
        value: profile,
        onRetry: () => ref.invalidate(orgProfileProvider),
        isEmpty: (OrgProfile? p) => p == null,
        emptyMessage: 'Could not find this gym\'s profile.',
        data: (OrgProfile? p) => _LetterheadForm(org: p!),
      ),
    );
  }
}

class _LetterheadForm extends ConsumerStatefulWidget {
  const _LetterheadForm({required this.org});

  final OrgProfile org;

  @override
  ConsumerState<_LetterheadForm> createState() => _LetterheadFormState();
}

class _LetterheadFormState extends ConsumerState<_LetterheadForm> {
  late final TextEditingController _name;
  late final TextEditingController _legalName;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _panNo;
  late final TextEditingController _taxNote;
  late final TextEditingController _terms;
  late final TextEditingController _fee;

  Map<LetterheadField, String> _errors = <LetterheadField, String>{};
  Uint8List? _newLogo;
  String? _newLogoType;
  bool _removeLogo = false;

  @override
  void initState() {
    super.initState();
    final OrgProfile o = widget.org;
    _name = TextEditingController(text: o.name);
    _legalName = TextEditingController(text: o.legalName ?? '');
    _address = TextEditingController(text: o.address ?? '');
    _phone = TextEditingController(text: o.phone ?? '');
    _email = TextEditingController(text: o.email ?? '');
    _panNo = TextEditingController(text: o.panNo ?? '');
    _taxNote = TextEditingController(text: o.taxNote ?? '');
    _terms = TextEditingController(text: o.invoiceTerms ?? '');
    _fee = TextEditingController(
      text: o.standardSignupFeePaisa == 0
          ? ''
          : fromPaisa(o.standardSignupFeePaisa),
    );
    for (final TextEditingController c in _all) {
      c.addListener(_rebuild);
    }
  }

  List<TextEditingController> get _all => <TextEditingController>[
    _name,
    _legalName,
    _address,
    _phone,
    _email,
    _panNo,
    _taxNote,
    _terms,
    _fee,
  ];

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final TextEditingController c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  ImageProvider? get _logoImage {
    if (_newLogo != null) return MemoryImage(_newLogo!);
    if (_removeLogo) return null;
    final String? url = ref
        .read(orgsRepositoryProvider)
        .logoUrl(widget.org.logoPath);
    return url == null ? null : NetworkImage(url);
  }

  bool get _hasLogo =>
      _newLogo != null ||
      (!_removeLogo && (widget.org.logoPath?.isNotEmpty ?? false));

  Future<void> _pickLogo(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
    } catch (error, stackTrace) {
      if (mounted) showFailureSnackBar(context, mapError(error, stackTrace));
      return;
    }
    if (picked == null || !mounted) return;

    final Uint8List bytes = await picked.readAsBytes();
    final String type = _logoContentType(picked.path);
    final String? problem = logoProblem(contentType: type, bytes: bytes.length);
    if (!mounted) return;
    if (problem != null) {
      showFailureSnackBar(context, AppFailure(FailureKind.invalid, problem));
      return;
    }
    setState(() {
      _newLogo = bytes;
      _newLogoType = type;
      _removeLogo = false;
    });
  }

  Future<void> _save() async {
    final LetterheadValidation result = validateLetterhead(
      name: _name.text,
      legalName: _legalName.text,
      address: _address.text,
      phone: _phone.text,
      email: _email.text,
      panNo: _panNo.text,
      taxNote: _taxNote.text,
      invoiceTerms: _terms.text,
      standardSignupFee: _fee.text,
    );
    setState(() => _errors = result.errors);
    if (!result.isValid) return;

    final LetterheadSaveResult outcome = await ref
        .read(letterheadSaveProvider.notifier)
        .save(
          values: result.values!,
          currentLogoPath: widget.org.logoPath,
          newLogo: _newLogo,
          newLogoType: _newLogoType,
          removeLogo: _removeLogo,
        );
    if (!mounted) return;
    switch (outcome) {
      case LetterheadSaved():
        setState(() {
          _newLogo = null;
          _newLogoType = null;
          _removeLogo = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Letterhead saved.')));
      case LetterheadSaveFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
    }
  }

  InputDecoration _decoration(
    String label,
    LetterheadField field, {
    String? hint,
    String? helper,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    helperMaxLines: 3,
    errorText: _errors[field],
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final bool saving = ref.watch(letterheadSaveProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: DockedAction(
        label: saving ? 'Saving…' : 'Save letterhead',
        icon: Icons.check,
        onPressed: saving ? null : () => unawaited(_save()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Brand.spaceMd),
        children: <Widget>[
          Text('Letterhead', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceXs),
          Text(
            'Printed at the top of every invoice and receipt.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          _logoRow(theme, saving),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Gym name', LetterheadField.name),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-legal-name'),
            controller: _legalName,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration(
              'Registered name',
              LetterheadField.legalName,
              helper:
                  'Printed instead of the gym name when it differs. Leave blank to use the gym name.',
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-address'),
            controller: _address,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration('Address', LetterheadField.address),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _decoration('Phone', LetterheadField.phone),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: _decoration('Email', LetterheadField.email),
          ),
          const SizedBox(height: Brand.spaceLg),
          const Divider(),
          const SizedBox(height: Brand.spaceSm),
          Text('Tax and terms', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-pan'),
            controller: _panNo,
            decoration: _decoration('PAN / VAT number', LetterheadField.panNo),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-tax-note'),
            controller: _taxNote,
            decoration: _decoration(
              'Tax note',
              LetterheadField.taxNote,
              hint: 'e.g. Prices include 13% VAT',
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-terms'),
            controller: _terms,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration(
              'Terms and footer',
              LetterheadField.invoiceTerms,
              helper: 'Printed at the bottom of every invoice and receipt.',
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('letterhead-fee'),
            controller: _fee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decoration(
              'Joining fee (${widget.org.currency})',
              LetterheadField.standardSignupFee,
              helper:
                  'The list price shown struck out when a joining fee is waived. Leave blank for none; it is never charged by itself.',
            ),
          ),
          const SizedBox(height: Brand.spaceLg),
          const Divider(),
          const SizedBox(height: Brand.spaceSm),
          Text('Preview', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceSm),
          LetterheadPreview(
            name: _name.text,
            legalName: _legalName.text,
            address: _address.text,
            phone: _phone.text,
            email: _email.text,
            panNo: _panNo.text,
            taxNote: _taxNote.text,
            invoiceTerms: _terms.text,
            logo: _logoImage,
          ),
          const SizedBox(height: Brand.spaceMd),
        ],
      ),
    );
  }

  Widget _logoRow(ThemeData theme, bool saving) {
    final ImageProvider? image = _logoImage;
    return Row(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Brand.radiusSmall),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: image == null
              ? Icon(
                  Icons.image_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : Image(image: image, fit: BoxFit.contain),
        ),
        const SizedBox(width: Brand.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'JPEG, PNG or WebP, up to 2 MB.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Brand.spaceSm),
              Wrap(
                spacing: Brand.spaceSm,
                children: <Widget>[
                  OutlinedButton.icon(
                    key: const ValueKey<String>('letterhead-logo-choose'),
                    onPressed: saving
                        ? null
                        : () => unawaited(_pickLogo(ImageSource.gallery)),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(_hasLogo ? 'Replace logo' : 'Choose logo'),
                  ),
                  if (_hasLogo)
                    TextButton.icon(
                      key: const ValueKey<String>('letterhead-logo-remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: saving
                          ? null
                          : () => setState(() {
                              _newLogo = null;
                              _newLogoType = null;
                              _removeLogo = true;
                            }),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
