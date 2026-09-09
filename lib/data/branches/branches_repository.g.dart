// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(branchesRepository)
final branchesRepositoryProvider = BranchesRepositoryProvider._();

final class BranchesRepositoryProvider
    extends
        $FunctionalProvider<
          BranchesRepository,
          BranchesRepository,
          BranchesRepository
        >
    with $Provider<BranchesRepository> {
  BranchesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchesRepositoryHash();

  @$internal
  @override
  $ProviderElement<BranchesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BranchesRepository create(Ref ref) {
    return branchesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchesRepository>(value),
    );
  }
}

String _$branchesRepositoryHash() =>
    r'f4535c313be3c8fdc84eff4ba4e946d73ea829ab';

/// Every branch the caller can read, loaded once and shared.
///
/// A `Future` provider rather than a plain one because the switcher, the
/// register form's home-branch picker and every screen that prints a branch
/// name all want the same list, and none of them should each issue their own
/// query for it.

@ProviderFor(branches)
final branchesProvider = BranchesProvider._();

/// Every branch the caller can read, loaded once and shared.
///
/// A `Future` provider rather than a plain one because the switcher, the
/// register form's home-branch picker and every screen that prints a branch
/// name all want the same list, and none of them should each issue their own
/// query for it.

final class BranchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Branch>>,
          List<Branch>,
          FutureOr<List<Branch>>
        >
    with $FutureModifier<List<Branch>>, $FutureProvider<List<Branch>> {
  /// Every branch the caller can read, loaded once and shared.
  ///
  /// A `Future` provider rather than a plain one because the switcher, the
  /// register form's home-branch picker and every screen that prints a branch
  /// name all want the same list, and none of them should each issue their own
  /// query for it.
  BranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchesHash();

  @$internal
  @override
  $FutureProviderElement<List<Branch>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Branch>> create(Ref ref) {
    return branches(ref);
  }
}

String _$branchesHash() => r'6ffba4bdbaa6ffa606cc675697699d7940bb6774';
