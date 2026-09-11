// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_photos_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberPhotosRepository)
final memberPhotosRepositoryProvider = MemberPhotosRepositoryProvider._();

final class MemberPhotosRepositoryProvider
    extends
        $FunctionalProvider<
          MemberPhotosRepository,
          MemberPhotosRepository,
          MemberPhotosRepository
        >
    with $Provider<MemberPhotosRepository> {
  MemberPhotosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberPhotosRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberPhotosRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberPhotosRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberPhotosRepository create(Ref ref) {
    return memberPhotosRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberPhotosRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberPhotosRepository>(value),
    );
  }
}

String _$memberPhotosRepositoryHash() =>
    r'4d928691ebe3ccce99cfcf47f665ab62c03018dd';

/// A signed URL for one member's photo.

@ProviderFor(memberPhotoUrl)
final memberPhotoUrlProvider = MemberPhotoUrlFamily._();

/// A signed URL for one member's photo.

final class MemberPhotoUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// A signed URL for one member's photo.
  MemberPhotoUrlProvider._({
    required MemberPhotoUrlFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'memberPhotoUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberPhotoUrlHash();

  @override
  String toString() {
    return r'memberPhotoUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String?;
    return memberPhotoUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberPhotoUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberPhotoUrlHash() => r'399ad269789563f5d31bf79a40d093f64cf55ea6';

/// A signed URL for one member's photo.

final class MemberPhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String?> {
  MemberPhotoUrlFamily._()
    : super(
        retry: null,
        name: r'memberPhotoUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A signed URL for one member's photo.

  MemberPhotoUrlProvider call(String? path) =>
      MemberPhotoUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'memberPhotoUrlProvider';
}

/// Signed URLs for a whole page of members, keyed by storage path.
///
/// One round trip per page. A list of forty members must not issue forty
/// signing requests while someone scrolls it.

@ProviderFor(memberPhotoUrls)
final memberPhotoUrlsProvider = MemberPhotoUrlsFamily._();

/// Signed URLs for a whole page of members, keyed by storage path.
///
/// One round trip per page. A list of forty members must not issue forty
/// signing requests while someone scrolls it.

final class MemberPhotoUrlsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  /// Signed URLs for a whole page of members, keyed by storage path.
  ///
  /// One round trip per page. A list of forty members must not issue forty
  /// signing requests while someone scrolls it.
  MemberPhotoUrlsProvider._({
    required MemberPhotoUrlsFamily super.from,
    required MemberPhotoPaths super.argument,
  }) : super(
         retry: null,
         name: r'memberPhotoUrlsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberPhotoUrlsHash();

  @override
  String toString() {
    return r'memberPhotoUrlsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    final argument = this.argument as MemberPhotoPaths;
    return memberPhotoUrls(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberPhotoUrlsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberPhotoUrlsHash() => r'58a41ad0f68ec73b9ade5b2b0c1f8af01417f504';

/// Signed URLs for a whole page of members, keyed by storage path.
///
/// One round trip per page. A list of forty members must not issue forty
/// signing requests while someone scrolls it.

final class MemberPhotoUrlsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, String>>,
          MemberPhotoPaths
        > {
  MemberPhotoUrlsFamily._()
    : super(
        retry: null,
        name: r'memberPhotoUrlsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Signed URLs for a whole page of members, keyed by storage path.
  ///
  /// One round trip per page. A list of forty members must not issue forty
  /// signing requests while someone scrolls it.

  MemberPhotoUrlsProvider call(MemberPhotoPaths paths) =>
      MemberPhotoUrlsProvider._(argument: paths, from: this);

  @override
  String toString() => r'memberPhotoUrlsProvider';
}
