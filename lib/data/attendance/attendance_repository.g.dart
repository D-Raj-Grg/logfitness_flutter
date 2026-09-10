// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider = AttendanceRepositoryProvider._();

final class AttendanceRepositoryProvider
    extends
        $FunctionalProvider<
          AttendanceRepository,
          AttendanceRepository,
          AttendanceRepository
        >
    with $Provider<AttendanceRepository> {
  AttendanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceRepository create(Ref ref) {
    return attendanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRepository>(value),
    );
  }
}

String _$attendanceRepositoryHash() =>
    r'f22a39c617b00fe37c1845cbacb0640db752db29';

/// A member's visit history, for the member detail screen's attendance tab.

@ProviderFor(memberAttendance)
final memberAttendanceProvider = MemberAttendanceFamily._();

/// A member's visit history, for the member detail screen's attendance tab.

final class MemberAttendanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AttendanceDetail>>,
          List<AttendanceDetail>,
          FutureOr<List<AttendanceDetail>>
        >
    with
        $FutureModifier<List<AttendanceDetail>>,
        $FutureProvider<List<AttendanceDetail>> {
  /// A member's visit history, for the member detail screen's attendance tab.
  MemberAttendanceProvider._({
    required MemberAttendanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberAttendanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberAttendanceHash();

  @override
  String toString() {
    return r'memberAttendanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AttendanceDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceDetail>> create(Ref ref) {
    final argument = this.argument as String;
    return memberAttendance(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberAttendanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberAttendanceHash() => r'901e2d43136878b6ff454d71b6e68d7c7b4dfa81';

/// A member's visit history, for the member detail screen's attendance tab.

final class MemberAttendanceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AttendanceDetail>>, String> {
  MemberAttendanceFamily._()
    : super(
        retry: null,
        name: r'memberAttendanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A member's visit history, for the member detail screen's attendance tab.

  MemberAttendanceProvider call(String memberId) =>
      MemberAttendanceProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberAttendanceProvider';
}
