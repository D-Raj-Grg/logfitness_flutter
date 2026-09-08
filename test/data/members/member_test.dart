import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  test('Member.fromJson maps a realistic PostgREST row', () {
    final json = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'org_id': '22222222-2222-2222-2222-222222222222',
      'home_branch_id': '33333333-3333-3333-3333-333333333333',
      'auth_user_id': null,
      'member_code': 'M-0042',
      'full_name': 'Anjali Shrestha',
      'phone': '9800000000',
      'email': null,
      'date_of_birth': '1995-06-12',
      'gender': 'female',
      'address': null,
      'photo_path': null,
      'emergency_contact_name': null,
      'emergency_contact_phone': null,
      'notes': null,
      'status': 'active',
      'joined_on': '2024-01-15',
      'left_on': null,
      'left_reason': null,
      'created_by': null,
      'created_at': '2024-01-15T09:30:00+00:00',
      'updated_at': '2024-01-15T09:30:00+00:00',
    };

    final member = Member.fromJson(json);

    expect(member.id, '11111111-1111-1111-1111-111111111111');
    expect(member.orgId, '22222222-2222-2222-2222-222222222222');
    expect(member.homeBranchId, '33333333-3333-3333-3333-333333333333');
    expect(member.authUserId, isNull);
    expect(member.memberCode, 'M-0042');
    expect(member.fullName, 'Anjali Shrestha');
    expect(member.phone, '9800000000');
    expect(member.email, isNull);
    // Date-only columns are pinned to UTC midnight so no offset can move
    // the day -- see lib/domain/format/plain_date.dart.
    expect(member.dateOfBirth, DateTime.utc(1995, 6, 12));
    expect(member.gender, MemberGender.female);
    expect(member.address, isNull);
    expect(member.photoPath, isNull);
    expect(member.emergencyContactName, isNull);
    expect(member.emergencyContactPhone, isNull);
    expect(member.notes, isNull);
    expect(member.status, MemberStatus.active);
    expect(member.joinedOn, DateTime.utc(2024, 1, 15));
    expect(member.leftOn, isNull);
    expect(member.leftReason, isNull);
    expect(member.createdBy, isNull);
    expect(member.createdAt, DateTime.parse('2024-01-15T09:30:00+00:00'));
    expect(member.updatedAt, DateTime.parse('2024-01-15T09:30:00+00:00'));
  });

  test('Member.fromJson maps a left member with left_on/left_reason set', () {
    final json = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'org_id': '22222222-2222-2222-2222-222222222222',
      'home_branch_id': '33333333-3333-3333-3333-333333333333',
      'auth_user_id': '44444444-4444-4444-4444-444444444444',
      'member_code': 'M-0043',
      'full_name': 'Bibek Karki',
      'phone': '9811111111',
      'email': 'bibek@example.com',
      'date_of_birth': null,
      'gender': 'male',
      'address': 'Kathmandu',
      'photo_path': 'members/44/photo.jpg',
      'emergency_contact_name': 'Sita Karki',
      'emergency_contact_phone': '9822222222',
      'notes': 'Prefers evening sessions.',
      'status': 'left',
      'joined_on': '2023-05-01',
      'left_on': '2024-02-01',
      'left_reason': 'Relocated',
      'created_by': '55555555-5555-5555-5555-555555555555',
      'created_at': '2023-05-01T08:00:00+00:00',
      'updated_at': '2024-02-01T10:00:00+00:00',
    };

    final member = Member.fromJson(json);

    expect(member.authUserId, '44444444-4444-4444-4444-444444444444');
    expect(member.email, 'bibek@example.com');
    expect(member.dateOfBirth, isNull);
    expect(member.gender, MemberGender.male);
    expect(member.address, 'Kathmandu');
    expect(member.photoPath, 'members/44/photo.jpg');
    expect(member.emergencyContactName, 'Sita Karki');
    expect(member.emergencyContactPhone, '9822222222');
    expect(member.notes, 'Prefers evening sessions.');
    expect(member.status, MemberStatus.left);
    expect(member.leftOn, DateTime.utc(2024, 2, 1));
    expect(member.leftReason, 'Relocated');
    expect(member.createdBy, '55555555-5555-5555-5555-555555555555');
  });
}
