// `register_member` returns `{member_id, member_code, sold}` merged with
// `renew_membership`'s own object when a plan was sold, so the two rows below
// are the only two shapes it can produce.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  group('RegisterMemberResult', () {
    test('maps a registration with no sale', () {
      final RegisterMemberResult result = RegisterMemberResult.fromJson(
        <String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'member_code': 'M00042',
          'sold': false,
        },
      );

      expect(result.memberId, '11111111-1111-4111-8111-111111111111');
      expect(result.memberCode, 'M00042');
      expect(result.sold, isFalse);
      // Every sale field is absent, not zero. A registration with no sale owes
      // nothing, and reading `duePaisa` as 0 would be indistinguishable from a
      // plan sold and paid in full.
      expect(result.membershipId, isNull);
      expect(result.invoiceId, isNull);
      expect(result.totalPaisa, isNull);
      expect(result.duePaisa, isNull);
      expect(result.startDate, isNull);
    });

    test('maps a registration with a plan sold and part-paid', () {
      final RegisterMemberResult result = RegisterMemberResult.fromJson(
        <String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'member_code': 'M00043',
          'sold': true,
          'membership_id': '44444444-4444-4444-8444-444444444444',
          'invoice_id': '55555555-5555-4555-8555-555555555555',
          'invoice_no': 'INV-2026-000123',
          'payment_id': '66666666-6666-4666-8666-666666666666',
          'start_date': '2026-09-10',
          'end_date': '2026-10-09',
          'total_paisa': 250000,
          'due_paisa': 100000,
        },
      );

      expect(result.sold, isTrue);
      expect(result.invoiceNo, 'INV-2026-000123');
      // `date`, not `timestamptz`: UTC midnight, no offset applied.
      expect(result.startDate, DateTime.utc(2026, 9, 10));
      expect(result.endDate, DateTime.utc(2026, 10, 9));
      // Integer paisa: NPR 2,500.00 billed, NPR 1,000.00 still owed.
      expect(result.totalPaisa, 250000);
      expect(result.duePaisa, 100000);
      expect(result.duePaisa, isA<int>());
    });

    test('maps a sale that took no money -- payment_id is null, not missing',
        () {
      final RegisterMemberResult result = RegisterMemberResult.fromJson(
        <String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'member_code': 'M00044',
          'sold': true,
          'membership_id': '44444444-4444-4444-8444-444444444444',
          'invoice_id': '55555555-5555-4555-8555-555555555555',
          'invoice_no': 'INV-2026-000124',
          'payment_id': null,
          'start_date': '2026-09-10',
          'end_date': null,
          'total_paisa': 250000,
          'due_paisa': 250000,
        },
      );

      expect(result.paymentId, isNull);
      // A session pack sold with no validity window genuinely has no end date.
      expect(result.endDate, isNull);
      expect(result.duePaisa, result.totalPaisa);
    });
  });

  test('ArchiveMemberResult maps the instant, not a day', () {
    final ArchiveMemberResult result = ArchiveMemberResult.fromJson(
      <String, dynamic>{
        'member_id': '11111111-1111-4111-8111-111111111111',
        'archived_at': '2026-09-07T05:15:00+00:00',
      },
    );

    expect(result.memberId, '11111111-1111-4111-8111-111111111111');
    expect(result.archivedAt, DateTime.parse('2026-09-07T05:15:00+00:00'));
  });

  group('MemberStatusResult', () {
    // `members.status` is trigger-derived and never written by the app, so the
    // RPC's own echo is the only sound way to learn what it became.
    test('maps the status set_member_left derived', () {
      final MemberStatusResult result = MemberStatusResult.fromJson(
        <String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'status': 'left',
        },
      );

      expect(result.status, MemberStatus.left);
    });

    test('maps the status reactivate_member derived', () {
      final MemberStatusResult result = MemberStatusResult.fromJson(
        <String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'status': 'expired',
        },
      );

      expect(result.status, MemberStatus.expired);
    });

    test('an unknown status fails loudly rather than defaulting', () {
      expect(
        () => MemberStatusResult.fromJson(<String, dynamic>{
          'member_id': '11111111-1111-4111-8111-111111111111',
          'status': 'suspended',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
