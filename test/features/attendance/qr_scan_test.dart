// The QR refusal wording, and the one refusal that is nobody's fault.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/features/attendance/scan_check_in_screen.dart';

void main() {
  test('every refusal reason has advice attached', () {
    for (final QrRefusal reason in QrRefusal.values) {
      expect(qrRefusalMessage(reason), isNotEmpty);
    }
  });

  test('an expired token is the retryable one', () {
    // Tokens are short-lived by design, so this is the common refusal and the
    // only one the member can fix themselves in a second.
    const expired = QrVerifyResult(valid: false, reason: QrRefusal.expired);
    expect(expired.isRetryable, isTrue);
    expect(qrRefusalMessage(QrRefusal.expired), contains('refresh'));

    for (final QrRefusal other in <QrRefusal>[
      QrRefusal.malformed,
      QrRefusal.badSignature,
      QrRefusal.notVisible,
    ]) {
      expect(QrVerifyResult(valid: false, reason: other).isRetryable, isFalse);
    }
  });

  test('a not_visible refusal points at the branch, not at the member', () {
    // It means RLS does not show this staff member that member — another org,
    // or a branch they do not cover. Telling the desk the code is bad would
    // send them looking in the wrong place.
    expect(qrRefusalMessage(QrRefusal.notVisible), contains('branch'));
  });

  test('a valid result carries who to check in', () {
    const result = QrVerifyResult(
      valid: true,
      memberId: 'm-1',
      memberCode: 'M-0042',
      fullName: 'Anjali Shrestha',
      homeBranchId: 'branch-1',
    );

    expect(result.valid, isTrue);
    expect(result.memberId, 'm-1');
    // Verifying is not checking in: the visit still goes through
    // check_in_member so the banner and the dues reach the desk.
    expect(result.reason, isNull);
  });

  test('QrRefusal covers what the function can return', () {
    expect(
      QrRefusal.values.map((e) => e.wire).toSet(),
      <String>{'malformed', 'bad_signature', 'expired', 'not_visible'},
    );
  });
}
