// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberships_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membershipsRepository)
final membershipsRepositoryProvider = MembershipsRepositoryProvider._();

final class MembershipsRepositoryProvider
    extends
        $FunctionalProvider<
          MembershipsRepository,
          MembershipsRepository,
          MembershipsRepository
        >
    with $Provider<MembershipsRepository> {
  MembershipsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipsRepositoryHash();

  @$internal
  @override
  $ProviderElement<MembershipsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembershipsRepository create(Ref ref) {
    return membershipsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipsRepository>(value),
    );
  }
}

String _$membershipsRepositoryHash() =>
    r'e3958df961e7404ea815de87c5bff64b94bee75d';
