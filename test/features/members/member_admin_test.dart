// Member administration: consent, archiving, and inviting.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeMembersRepository implements MembersRepository {
  int updateCallCount = 0;
  Map<String, Object?> lastUpdate = <String, Object?>{};
  String? invitedEmail;
  String? archivedReason;
  int archiveCallCount = 0;
  Object? error;

  @override
  Future<void> updateMember({
    required String memberId,
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
    required bool notificationsOptOut,
  }) async {
    updateCallCount++;
    lastUpdate = <String, Object?>{
      'fullName': fullName,
      'notificationsOptOut': notificationsOptOut,
      'dateOfBirth': dateOfBirth,
    };
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) {
      throw error!;
    }
  }

  @override
  Future<String> inviteMemberToApp({
    required String memberId,
    required String email,
  }) async {
    invitedEmail = email;
    if (error != null) {
      throw error!;
    }
    return email;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakeMembersRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeMembersRepository();
    container = ProviderContainer(
      overrides: [membersRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen<bool>(memberAdminProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  MemberAdmin notifier() => container.read(memberAdminProvider.notifier);

  test('consent is always sent, never left to a default', () async {
    // Every enqueue job upstream checks `notifications_opt_out`. A form that
    // defaulted it would opt someone back in as a side effect of correcting
    // their phone number.
    await notifier().save(
      memberId: 'm-1',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      notificationsOptOut: true,
    );

    expect(repository.lastUpdate['notificationsOptOut'], isTrue);
  });

  test('a date of birth stays a calendar day', () async {
    await notifier().save(
      memberId: 'm-1',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      notificationsOptOut: false,
      dateOfBirth: DateTime.utc(1995, 6, 12),
    );

    final dob = repository.lastUpdate['dateOfBirth']! as DateTime;
    expect(dob.isUtc, isTrue);
    expect(dob, DateTime.utc(1995, 6, 12));
  });

  test('a double save writes once', () async {
    final first = notifier().save(
      memberId: 'm-1',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      notificationsOptOut: false,
    );
    final second = notifier().save(
      memberId: 'm-1',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      notificationsOptOut: false,
    );
    await Future.wait<MemberAdminOutcome>(
      <Future<MemberAdminOutcome>>[first, second],
    );

    expect(repository.updateCallCount, 1);
  });

  test('a refusal reaches the caller as a refusal', () async {
    repository.error = const PostgrestException(
      message: 'permission denied for table members',
      code: '42501',
    );

    final outcome = await notifier().save(
      memberId: 'm-1',
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      homeBranchId: 'branch-1',
      notificationsOptOut: false,
    );

    expect(outcome, isA<MemberAdminFailed>());
    expect((outcome as MemberAdminFailed).isRefusal, isTrue);
    expect(outcome.failure.kind, FailureKind.refused);
  });

  test('an invitation reports the address it went to', () async {
    // A typo is otherwise only discovered when the member says they never got
    // it.
    final outcome = await notifier().inviteToApp(
      memberId: 'm-1',
      email: 'anjali@example.com',
    );

    expect(outcome, isA<MemberAdminSucceeded>());
    expect(
      (outcome as MemberAdminSucceeded).message,
      contains('anjali@example.com'),
    );
    expect(repository.invitedEmail, 'anjali@example.com');
  });

  test('gender labels cover the whole enum', () {
    for (final MemberGender gender in MemberGender.values) {
      expect(memberGenderLabel(gender), isNotEmpty);
    }
    expect(memberGenderLabel(MemberGender.female), 'Female');
  });
}
