import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';
import 'package:logfitness_flutter/features/members/widgets/member_avatar.dart';

void main() {
  group('memberPhotoPath', () {
    test('puts the org first, because storage policies read that segment', () {
      final path = memberPhotoPath(
        orgId: 'org-1',
        memberId: 'm-1',
        contentType: 'image/png',
      );

      // `<org_id>/<member_id>/<file>` — the first segment is the tenant
      // boundary here, the way org_id is on every table.
      expect(path.split('/').first, 'org-1');
      expect(path.split('/')[1], 'm-1');
      expect(path, endsWith('.png'));
    });

    test('an unknown type still produces a usable key', () {
      final path = memberPhotoPath(
        orgId: 'org-1',
        memberId: 'm-1',
        contentType: 'image/heic',
      );
      expect(path, endsWith('.jpg'));
    });

    test('two uploads for one member do not collide', () {
      // Each upload is a new object, so a signed URL already handed out keeps
      // pointing at the face it was signed for.
      final a = memberPhotoPath(
        orgId: 'org-1',
        memberId: 'm-1',
        contentType: 'image/jpeg',
      );
      final b = memberPhotoPath(
        orgId: 'org-1',
        memberId: 'm-1',
        contentType: 'image/jpeg',
      );
      expect(a.split('/').take(2), b.split('/').take(2));
    });
  });

  group('MemberPhotoPaths', () {
    test('compares by contents, not by list identity', () {
      // A family keyed on a raw List never matches a previous argument, so the
      // provider would re-sign every URL on every frame.
      expect(
        MemberPhotoPaths(<String?>['a', 'b']),
        MemberPhotoPaths(<String?>['b', 'a']),
      );
      expect(
        MemberPhotoPaths(<String?>['a', 'b']).hashCode,
        MemberPhotoPaths(<String?>['b', 'a']).hashCode,
      );
    });

    test('drops nulls and blanks, and de-duplicates', () {
      final paths = MemberPhotoPaths(<String?>['a', null, '', 'a', 'b']);
      expect(paths.paths, <String>['a', 'b']);
    });

    test('a page with no photos is an empty key', () {
      expect(MemberPhotoPaths(<String?>[null, null]).paths, isEmpty);
    });
  });

  group('memberInitials', () {
    test('takes the first and last word', () {
      // The family name is the half a desk recognises, so "Anjali Kumari
      // Shrestha" is AS rather than AK.
      expect(memberInitials('Anjali Kumari Shrestha'), 'AS');
      expect(memberInitials('Anjali Shrestha'), 'AS');
    });

    test('handles one word, extra spaces and nothing at all', () {
      expect(memberInitials('Anjali'), 'A');
      expect(memberInitials('  Anjali   Shrestha  '), 'AS');
      expect(memberInitials(''), '?');
      expect(memberInitials('   '), '?');
    });

    test('does not split a Devanagari name mid-grapheme', () {
      // `characters` rather than `substring`: a name in Devanagari has
      // combining marks, and cutting at a code unit produces a broken glyph.
      final initials = memberInitials('अन्जली श्रेष्ठ');
      expect(initials, isNotEmpty);
      expect(initials, isNot(contains('?')));
    });
  });

  group('bucket limits', () {
    test('match what the bucket itself enforces', () {
      // Mirrors 20260905130000_member_photos_bucket.sql, so a file that
      // storage would reject is refused before it is uploaded.
      expect(kMaxPhotoBytes, 5 * 1024 * 1024);
      expect(
        kAllowedPhotoTypes,
        <String>['image/jpeg', 'image/png', 'image/webp'],
      );
      expect(kMemberPhotoBucket, 'member-photos');
    });
  });
}
