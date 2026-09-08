// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitors_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(visitorsRepository)
final visitorsRepositoryProvider = VisitorsRepositoryProvider._();

final class VisitorsRepositoryProvider
    extends
        $FunctionalProvider<
          VisitorsRepository,
          VisitorsRepository,
          VisitorsRepository
        >
    with $Provider<VisitorsRepository> {
  VisitorsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitorsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitorsRepositoryHash();

  @$internal
  @override
  $ProviderElement<VisitorsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VisitorsRepository create(Ref ref) {
    return visitorsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VisitorsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VisitorsRepository>(value),
    );
  }
}

String _$visitorsRepositoryHash() =>
    r'1098a01e33af4cf66adfc3a4eb4aa4820abf3f53';
