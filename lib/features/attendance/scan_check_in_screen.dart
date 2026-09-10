// Scanning a member's QR code at the door.
//
// This is the one thing a phone does better than the console: the desk holds
// the camera up, the member holds up their screen, and the visit is recorded.
// Everything else in the staff app is parity; this is the reason to reach for
// the phone.
//
// Two deliberate properties:
//
// Verifying is not checking in. `verify_qr_token` says whose token this is;
// `check_in_member` records the visit and returns the banner and the dues. So
// a scanned member still goes through exactly the same "what is true about
// this person" surface a manually found one does — a scan must not become a
// way to wave past an expired membership.
//
// Verification is staff-only in the database
// (`20260905150400_only_staff_verify_qr_tokens.sql`), so a member cannot scan
// their own screen and let themselves in.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/attendance/attendance_repository.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/attendance/check_in_controller.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// What to tell the desk when a scan is refused.
String qrRefusalMessage(QrRefusal reason) => switch (reason) {
      // The common one, and the only one that is nobody's fault: tokens are
      // short-lived on purpose.
      QrRefusal.expired =>
        'That code has expired. Ask them to refresh it in their app.',
      QrRefusal.malformed =>
        'That is not a member code from this app.',
      QrRefusal.badSignature =>
        'That code could not be verified. Find the member by phone instead.',
      QrRefusal.notVisible =>
        'That member is not one this account can see. Check the branch you '
            'are signed in to.',
    };

class ScanCheckInScreen extends ConsumerStatefulWidget {
  const ScanCheckInScreen({super.key});

  @override
  ConsumerState<ScanCheckInScreen> createState() => _ScanCheckInScreenState();
}

class _ScanCheckInScreenState extends ConsumerState<ScanCheckInScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  /// Guards against the detector firing repeatedly while a round trip is in
  /// flight. `noDuplicates` handles the same code twice; this handles the
  /// window between a detection and the check-in landing.
  bool _handling = false;

  CheckInResult? _lastResult;
  String? _lastMessage;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan to check in'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Torch',
            onPressed: () => _scanner.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: 'Switch camera',
            onPressed: () => _scanner.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MobileScanner(
              controller: _scanner,
              onDetect: _onDetect,
              errorBuilder: (BuildContext context, MobileScannerException error) {
                // A camera that will not start is a dead screen unless it says
                // so — and the desk needs to know to fall back to phone search.
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Brand.spaceLg),
                    child: Text(
                      'The camera could not start (${error.errorCode.name}). '
                      'Find the member by phone instead.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_lastResult != null || _lastMessage != null)
            Padding(
              padding: const EdgeInsets.all(Brand.spaceMd),
              child: _ScanOutcome(
                result: _lastResult,
                message: _lastMessage,
                onDismiss: () => setState(() {
                  _lastResult = null;
                  _lastMessage = null;
                }),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) {
      return;
    }
    final String? token = capture.barcodes
        .map((Barcode b) => b.rawValue)
        .firstWhere((String? v) => v != null && v.isNotEmpty, orElse: () => null);
    if (token == null) {
      return;
    }

    setState(() => _handling = true);
    try {
      await _verifyAndCheckIn(token);
    } finally {
      if (mounted) {
        setState(() => _handling = false);
      }
    }
  }

  Future<void> _verifyAndCheckIn(String token) async {
    final QrVerifyResult verified;
    try {
      verified =
          await ref.read(attendanceRepositoryProvider).verifyQrToken(token);
    } catch (error, stackTrace) {
      if (mounted) {
        showFailureSnackBar(context, mapError(error, stackTrace));
      }
      return;
    }

    if (!mounted) {
      return;
    }

    if (!verified.valid || verified.memberId == null) {
      setState(() {
        _lastResult = null;
        _lastMessage = verified.reason == null
            ? 'That code could not be verified.'
            : qrRefusalMessage(verified.reason!);
      });
      return;
    }

    final scope = ref.read(branchScopeProvider);
    final branchId = scope.selectedBranchId ?? verified.homeBranchId;
    if (branchId == null) {
      setState(() => _lastMessage =
          'No branch is selected, so there is nowhere to record this visit.');
      return;
    }

    // Verified only says who they are. The visit still goes through
    // `check_in_member`, so the banner and the dues reach the desk exactly as
    // they would for a member found by phone.
    final outcome = await ref.read(checkInControllerProvider.notifier).checkIn(
          memberId: verified.memberId!,
          branchId: branchId,
          // Records how the visit was taken, which the attendance log shows.
          method: AttendanceMethod.qr,
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case CheckInRecorded(:final result):
        setState(() {
          _lastResult = result;
          _lastMessage = null;
        });
      case CheckInDuplicate(:final result):
        setState(() {
          _lastResult = null;
          _lastMessage =
              '${result.member?.fullName ?? 'That member'} is already checked '
              'in today. Use the check-in screen to record a second visit.';
        });
      case CheckInFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}

class _ScanOutcome extends StatelessWidget {
  const _ScanOutcome({
    required this.result,
    required this.message,
    required this.onDismiss,
  });

  final CheckInResult? result;
  final String? message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attention = result?.needsAttention ?? true;
    final background =
        attention ? scheme.errorContainer : scheme.primaryContainer;
    final foreground =
        attention ? scheme.onErrorContainer : scheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message ??
                  '${result?.member?.fullName ?? 'Member'} checked in',
              style: TextStyle(color: foreground),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: foreground),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
