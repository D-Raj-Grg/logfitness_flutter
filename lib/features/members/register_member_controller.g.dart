// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_member_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterMember)
final registerMemberProvider = RegisterMemberProvider._();

final class RegisterMemberProvider
    extends $NotifierProvider<RegisterMember, bool> {
  RegisterMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerMemberHash();

  @$internal
  @override
  RegisterMember create() => RegisterMember();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$registerMemberHash() => r'4c30563d9f1dcae120c85867ccb829dc7c85d4ac';

abstract class _$RegisterMember extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
