// Registration, and the half-failure that matters most: a member created
// whose visitor row could not be linked.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/members/register_member_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeMembersRepository implements MembersRepository {
  int registerCallCount = 0;
  Map<String, Object?> lastArgs = <String, Object?>{};
  Object? error;

  @override
  Future<RegisterMemberResult> registerMember({
    required String fullName,
    required String phone,
    required String homeBranchId,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    String? planId,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    DateTime? startDate,
  }) async {
    registerCallCount++;
    lastArgs = <String, Object?>{
      'fullName': fullName,
      'phone': phone,
      'planId': planId,
      'discountPaisa': discountPaisa,
      'amountPaidPaisa': amountPaidPaisa,
      'startDate': startDate,
      'dateOfBirth': dateOfBirth,
    };
    // Let a concurrent second call observe the in-flight guard.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) {
      throw error!;
    }
    return const RegisterMemberResult(
      memberId: 'm-1',
      memberCode: 'M-0042',
      sold: false,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeVisitorsRepository implements VisitorsRepository {
  int convertCallCount = 0;
  Object? convertError;

  @override
  Future<void> convertVisitor(String visitorId, String memberId) async {
    convertCallCount++;
    if (convertError != null) {
      throw convertError!;
    }
  }

  @override
  Future<VisitorPage> listVisitors(VisitorListFilter filter) async =>
      const VisitorPage(rows: <Visitor>[], total: 0, page: 1, pageSize: 20);

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakeMembersRepository members;
  late _FakeVisitorsRepository visitors;
  late ProviderContainer container;

  setUp(() {
    members = _FakeMembersRepository();
    visitors = _FakeVisitorsRepository();
    container = ProviderContainer(
      overrides: [
        membersRepositoryProvider.overrideWithValue(members),
        visitorsRepositoryProvider.overrideWithValue(visitors),
      ],
    );


    // The screen holds this provider with `ref.watch`; without an equivalent
    // subscription here the notifier auto-disposes across the first await and
    // the test fails on a disposed Ref rather than on anything real.
    container.listen<bool>(registerMemberProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  RegisterMember notifier() => container.read(registerMemberProvider.notifier);

  test('a plain registration sends no sale', () async {
    final outcome = await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
    );

    expect(outcome, isA<RegisterSucceeded>());
    expect(members.lastArgs['planId'], isNull);
    expect(members.lastArgs['amountPaidPaisa'], 0);
    expect(members.lastArgs['startDate'], isNull);
    // No visitor to link, so nothing was linked.
    expect(visitors.convertCallCount, 0);
  });

  test('a double submit reaches the RPC once', () async {
    // register_member is not idempotent: a second call would create a second
    // member and take the money twice.
    final first = notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
    );
    final second = notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
    );

    final results = await Future.wait<RegisterOutcome>(<Future<RegisterOutcome>>[
      first,
      second,
    ]);

    expect(members.registerCallCount, 1);
    expect(results.whereType<RegisterSucceeded>(), hasLength(1));
    expect(results.whereType<RegisterFailed>(), hasLength(1));
  });

  test('a refusal comes back as a refusal, and creates nothing', () async {
    members.error = const PostgrestException(
      message: 'new row violates row-level security policy',
      code: '42501',
    );

    final outcome = await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
    );

    expect(outcome, isA<RegisterFailed>());
    expect((outcome as RegisterFailed).isRefusal, isTrue);
    expect(outcome.failure.kind, FailureKind.refused);
  });

  test('a phone already in the org says so, not "record already exists"',
      () async {
    members.error = const PostgrestException(
      message:
          'duplicate key value violates unique constraint "members_org_phone_key"',
      code: '23505',
    );

    final outcome = await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
    );

    expect(outcome, isA<RegisterFailed>());
    expect(
      (outcome as RegisterFailed).failure.message,
      contains('already has that phone number'),
    );
  });

  test('converting a walk-in registers, then links', () async {
    final outcome = await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      visitorId: 'v-1',
    );

    expect(outcome, isA<RegisterSucceeded>());
    expect((outcome as RegisterSucceeded).isFullySucceeded, isTrue);
    expect(members.registerCallCount, 1);
    expect(visitors.convertCallCount, 1);
  });

  test('a failed link still reports the member as registered', () async {
    visitors.convertError = const PostgrestException(
      message: 'You cannot change a visitor logged at another branch',
      code: '42501',
    );

    final outcome = await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      visitorId: 'v-1',
    );

    // The member and the money are real. Calling this a failed registration
    // would send the desk to register them a second time.
    expect(outcome, isA<RegisterSucceeded>());
    final succeeded = outcome as RegisterSucceeded;
    expect(succeeded.result.memberCode, 'M-0042');
    expect(succeeded.isFullySucceeded, isFalse);
    expect(succeeded.linkFailure, isNotNull);
    expect(succeeded.linkFailure!.isRefusal, isTrue);
  });

  test('a date of birth stays a calendar day', () async {
    await notifier().submit(
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      dateOfBirth: DateTime.utc(1995, 6, 12),
    );

    final dob = members.lastArgs['dateOfBirth']! as DateTime;
    expect(dob.isUtc, isTrue);
    expect(dob.hour, 0);
    expect(dob, DateTime.utc(1995, 6, 12));
  });
}
