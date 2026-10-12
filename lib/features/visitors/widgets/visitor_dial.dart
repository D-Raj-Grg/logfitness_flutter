import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';

/// Opens the phone's dialler. Said out loud when nothing will take a `tel:`
/// link, because a silent tap reads as a broken button.
Future<void> dialPhone(BuildContext context, String phone) async {
  final String number = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  final bool opened = await launchUrl(Uri(scheme: 'tel', path: number))
      .catchError((Object _) => false);
  if (!opened && context.mounted) {
    showFailureSnackBar(
      context,
      AppFailure(FailureKind.unknown, 'Could not open the dialler. Call $phone by hand.'),
    );
  }
}
