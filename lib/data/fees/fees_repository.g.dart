// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fees_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feesRepository)
final feesRepositoryProvider = FeesRepositoryProvider._();

final class FeesRepositoryProvider
    extends $FunctionalProvider<FeesRepository, FeesRepository, FeesRepository>
    with $Provider<FeesRepository> {
  FeesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feesRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeesRepository create(Ref ref) {
    return feesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeesRepository>(value),
    );
  }
}

String _$feesRepositoryHash() => r'43d970e5df38606fd226daf91031cae32fa4858a';
