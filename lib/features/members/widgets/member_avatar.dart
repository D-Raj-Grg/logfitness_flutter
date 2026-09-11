// A member's face, or the next best thing.
//
// The bucket is private, so a photo is a path that has to be signed before it
// can be shown. Every failure along that route — no photo, an expired
// signature, a dead network, an object that has gone missing — lands on the
// same fallback rather than on an error: initials. A face is worth having and
// never worth a broken screen, which is the same rule the repository follows.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';

/// The initials shown when there is no photo to show.
///
/// First and last word, so "Anjali Kumari Shrestha" reads AS rather than AK —
/// the family name is the half a desk recognises.
String memberInitials(String fullName) {
  final words = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return '?';
  }
  if (words.length == 1) {
    return words.single.characters.first.toUpperCase();
  }
  return (words.first.characters.first + words.last.characters.first)
      .toUpperCase();
}

class MemberAvatar extends ConsumerWidget {
  const MemberAvatar({
    required this.fullName,
    this.photoPath,
    this.signedUrl,
    this.radius = 22,
    super.key,
  });

  final String fullName;

  /// The storage path off the member row.
  final String? photoPath;

  /// A URL already signed by the caller — how a list avoids one signing
  /// request per row. When given, [photoPath] is not looked up.
  final String? signedUrl;

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (signedUrl != null) {
      return _avatar(context, signedUrl);
    }
    if (photoPath == null || photoPath!.isEmpty) {
      return _avatar(context, null);
    }

    final url = ref.watch(memberPhotoUrlProvider(photoPath));
    return _avatar(context, url.value);
  }

  Widget _avatar(BuildContext context, String? url) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      // Reached when the image fails to load as well as when there is none,
      // because `foregroundImage` falls back to the child on error.
      onForegroundImageError: url == null ? null : (_, _) {},
      child: Text(
        memberInitials(fullName),
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
