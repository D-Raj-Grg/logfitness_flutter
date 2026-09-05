// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membersRepository)
final membersRepositoryProvider = MembersRepositoryProvider._();

final class MembersRepositoryProvider
    extends
        $FunctionalProvider<
          MembersRepository,
          MembersRepository,
          MembersRepository
        >
    with $Provider<MembersRepository> {
  MembersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membersRepositoryHash();

  @$internal
  @override
  $ProviderElement<MembersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembersRepository create(Ref ref) {
    return membersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembersRepository>(value),
    );
  }
}

String _$membersRepositoryHash() => r'07d642eac1ca7e36bd89c904ac2aa9558d0fdc1b';
