// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_cards_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberCardsRepository)
final memberCardsRepositoryProvider = MemberCardsRepositoryProvider._();

final class MemberCardsRepositoryProvider
    extends
        $FunctionalProvider<
          MemberCardsRepository,
          MemberCardsRepository,
          MemberCardsRepository
        >
    with $Provider<MemberCardsRepository> {
  MemberCardsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberCardsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberCardsRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberCardsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberCardsRepository create(Ref ref) {
    return memberCardsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberCardsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberCardsRepository>(value),
    );
  }
}

String _$memberCardsRepositoryHash() =>
    r'9bf098e20e128f2ede742c0882db83fdc0db075d';

/// The member's live card, for the "Access card" tile.

@ProviderFor(memberLiveCard)
final memberLiveCardProvider = MemberLiveCardFamily._();

/// The member's live card, for the "Access card" tile.

final class MemberLiveCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberCard?>,
          MemberCard?,
          FutureOr<MemberCard?>
        >
    with $FutureModifier<MemberCard?>, $FutureProvider<MemberCard?> {
  /// The member's live card, for the "Access card" tile.
  MemberLiveCardProvider._({
    required MemberLiveCardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberLiveCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberLiveCardHash();

  @override
  String toString() {
    return r'memberLiveCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemberCard?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberCard?> create(Ref ref) {
    final argument = this.argument as String;
    return memberLiveCard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberLiveCardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberLiveCardHash() => r'a8f0f3a49bbba70e612230a813b15db5b00101b4';

/// The member's live card, for the "Access card" tile.

final class MemberLiveCardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemberCard?>, String> {
  MemberLiveCardFamily._()
    : super(
        retry: null,
        name: r'memberLiveCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The member's live card, for the "Access card" tile.

  MemberLiveCardProvider call(String memberId) =>
      MemberLiveCardProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberLiveCardProvider';
}
