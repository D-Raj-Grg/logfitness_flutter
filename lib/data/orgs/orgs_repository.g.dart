// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orgs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orgsRepository)
final orgsRepositoryProvider = OrgsRepositoryProvider._();

final class OrgsRepositoryProvider
    extends $FunctionalProvider<OrgsRepository, OrgsRepository, OrgsRepository>
    with $Provider<OrgsRepository> {
  OrgsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orgsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orgsRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrgsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrgsRepository create(Ref ref) {
    return orgsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrgsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrgsRepository>(value),
    );
  }
}

String _$orgsRepositoryHash() => r'f450a5dc23172fb1d0b831dc96f15942ebbba7d3';
