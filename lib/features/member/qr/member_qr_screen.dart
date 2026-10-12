// Member check-in QR. Mints a short-lived token via the `mint_qr_token` RPC,
// renders it, and re-mints before it expires. Staff scan it with
// `verify_qr_token`.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/qr/qr_token_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';

class MemberQrScreen extends ConsumerStatefulWidget {
  const MemberQrScreen({super.key});

  @override
  ConsumerState<MemberQrScreen> createState() => _MemberQrScreenState();
}

class _MemberQrScreenState extends ConsumerState<MemberQrScreen>
    with WidgetsBindingObserver {
  /// Re-mint this long before expiry so a code on screen is never stale at
  /// the desk.
  static const Duration _refreshMargin = Duration(seconds: 20);

  QrToken? _token;
  AppFailure? _failure;
  bool _loading = false;
  Timer? _refreshTimer;
  Timer? _tick;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    _mint();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Timers can be suspended in the background; a code shown on resume may
    // be long expired.
    if (state == AppLifecycleState.resumed) {
      final token = _token;
      if (token == null || DateTime.now().isAfter(token.expiresAt)) {
        _mint();
      }
    }
  }

  void _onTick() {
    final token = _token;
    if (token == null || !mounted) return;
    final left = token.expiresAt.difference(DateTime.now());
    setState(() => _remaining = left.isNegative ? Duration.zero : left);
  }

  Future<void> _mint() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final token = await ref.read(qrTokenRepositoryProvider).mint();
      if (!mounted) return;
      _refreshTimer?.cancel();
      var wait = token.ttl - _refreshMargin;
      if (wait < const Duration(seconds: 5)) {
        wait = token.ttl * 0.6;
      }
      _refreshTimer = Timer(wait, _mint);
      setState(() {
        _token = token;
        _remaining = token.ttl;
        _loading = false;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      final failure = mapError(error, stackTrace);
      // Retry automatically only on connectivity loss; a refusal will not fix
      // itself and retrying it would just hammer the RPC.
      _refreshTimer?.cancel();
      if (failure.kind == FailureKind.offline) {
        _refreshTimer = Timer(const Duration(seconds: 10), _mint);
      }
      setState(() {
        _failure = failure;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final token = _token;
    final expired = token != null && _remaining == Duration.zero;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Brand.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Check-in', style: theme.textTheme.headlineSmall),
                const SizedBox(height: Brand.spaceSm),
                Text(
                  'Show this code at the front desk.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: Brand.spaceLg),
                if (_failure != null && token == null)
                  FailureView(failure: _failure!, onRetry: _mint)
                else if (token == null)
                  const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...<Widget>[
                  Semantics(
                    label: 'Check-in QR code',
                    child: Container(
                      padding: const EdgeInsets.all(Brand.spaceMd),
                      decoration: BoxDecoration(
                        // Always white: scanners need dark-on-light contrast
                        // regardless of the app theme.
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Brand.radiusLarge),
                      ),
                      child: Opacity(
                        opacity: expired ? 0.15 : 1,
                        child: QrImageView(
                          data: token.token,
                          size: 240,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Brand.spaceMd),
                  Text(
                    expired
                        ? 'Code expired'
                        : 'Refreshes automatically · ${_remaining.inSeconds}s',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (_failure != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceMd),
                    FailureView(failure: _failure!, onRetry: _mint),
                  ],
                  const SizedBox(height: Brand.spaceMd),
                  TextButton.icon(
                    onPressed: _loading ? null : _mint,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh now'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
