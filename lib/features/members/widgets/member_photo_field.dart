// Taking or replacing a member's photo.
//
// Separate from the rest of the edit form on purpose: the photo uploads the
// moment it is picked, rather than waiting for Save. A member already exists
// by the time this widget is on screen, so a failed upload costs the photo and
// nothing else — which is the same reason photo capture was kept out of
// registration, where a failure would have cost the member and the payment
// taken with them.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';
import 'package:logfitness_flutter/features/members/widgets/member_avatar.dart';

/// Maps a picked file's extension to the MIME type storage expects.
///
/// `image_picker` re-encodes to JPEG whenever `imageQuality` is set, but a
/// pick straight from the gallery can still arrive as PNG or WebP, so the
/// extension is read rather than assumed.
String photoContentTypeFor(String filePath) {
  final lower = filePath.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  return 'image/jpeg';
}

class MemberPhotoField extends ConsumerWidget {
  const MemberPhotoField({required this.member, this.picker, super.key});

  final Member member;

  /// Injectable so a widget test never reaches for a camera.
  final ImagePicker? picker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(memberAdminProvider);
    final hasPhoto = member.photoPath != null && member.photoPath!.isNotEmpty;

    return Row(
      children: <Widget>[
        MemberAvatar(
          fullName: member.fullName,
          photoPath: member.photoPath,
          radius: 32,
        ),
        const SizedBox(width: Brand.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                hasPhoto ? 'Photo' : 'No photo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                // Says it is optional, because it is: `members.photo_path` is
                // nullable and every surface falls back to initials.
                'Optional. Helps the desk recognise them at check-in.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: Brand.spaceSm),
              Wrap(
                spacing: Brand.spaceSm,
                children: <Widget>[
                  OutlinedButton.icon(
                    key: const ValueKey<String>('member-photo-camera'),
                    onPressed: busy
                        ? null
                        : () => _pick(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(hasPhoto ? 'Retake' : 'Take photo'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('member-photo-gallery'),
                    onPressed: busy
                        ? null
                        : () => _pick(context, ref, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose'),
                  ),
                  if (hasPhoto)
                    TextButton.icon(
                      key: const ValueKey<String>('member-photo-remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: busy ? null : () => _clear(context, ref),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final XFile? picked;
    try {
      picked = await (picker ?? ImagePicker()).pickImage(
        source: source,
        // Downscaled and re-encoded on the way out. The bucket caps an object
        // at 5 MB and a modern phone camera clears that on its own, so
        // resizing here is what keeps the upload inside the limit -- and off a
        // Nepali mobile connection for longer than it needs to be.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (error, stackTrace) {
      if (context.mounted) {
        // A denied camera permission arrives here, and silently doing nothing
        // is indistinguishable from a broken button.
        showFailureSnackBar(context, mapError(error, stackTrace));
      }
      return;
    }

    if (picked == null || !context.mounted) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!context.mounted) {
      return;
    }

    final outcome = await ref.read(memberAdminProvider.notifier).setPhoto(
          memberId: member.id,
          orgId: member.orgId,
          bytes: bytes,
          contentType: photoContentTypeFor(picked.path),
        );

    if (!context.mounted) {
      return;
    }
    _report(context, outcome);
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(memberAdminProvider.notifier).clearPhoto(
          memberId: member.id,
          path: member.photoPath,
        );
    if (!context.mounted) {
      return;
    }
    _report(context, outcome);
  }

  void _report(BuildContext context, MemberAdminOutcome outcome) {
    switch (outcome) {
      case MemberAdminSucceeded(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message ?? 'Saved')));
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
