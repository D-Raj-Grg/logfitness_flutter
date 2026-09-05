// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_lookup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemberLookup)
final memberLookupProvider = MemberLookupProvider._();

final class MemberLookupProvider
    extends $AsyncNotifierProvider<MemberLookup, List<Member>> {
  MemberLookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberLookupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberLookupHash();

  @$internal
  @override
  MemberLookup create() => MemberLookup();
}

String _$memberLookupHash() => r'73377950864ec82681ffefdbf44ffca520982ab2';

abstract class _$MemberLookup extends $AsyncNotifier<List<Member>> {
  FutureOr<List<Member>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Member>>, List<Member>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Member>>, List<Member>>,
              AsyncValue<List<Member>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
