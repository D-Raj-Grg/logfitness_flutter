// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Principal {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Principal);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Principal()';
}


}

/// @nodoc
class $PrincipalCopyWith<$Res>  {
$PrincipalCopyWith(Principal _, $Res Function(Principal) __);
}


/// Adds pattern-matching-related methods to [Principal].
extension PrincipalPatterns on Principal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PrincipalSignedOut value)?  signedOut,TResult Function( PrincipalStaff value)?  staff,TResult Function( PrincipalMember value)?  member,TResult Function( PrincipalStaffPendingRefresh value)?  staffPendingRefresh,TResult Function( PrincipalMemberPendingRefresh value)?  memberPendingRefresh,TResult Function( PrincipalNotLinked value)?  notLinked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PrincipalSignedOut() when signedOut != null:
return signedOut(_that);case PrincipalStaff() when staff != null:
return staff(_that);case PrincipalMember() when member != null:
return member(_that);case PrincipalStaffPendingRefresh() when staffPendingRefresh != null:
return staffPendingRefresh(_that);case PrincipalMemberPendingRefresh() when memberPendingRefresh != null:
return memberPendingRefresh(_that);case PrincipalNotLinked() when notLinked != null:
return notLinked(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PrincipalSignedOut value)  signedOut,required TResult Function( PrincipalStaff value)  staff,required TResult Function( PrincipalMember value)  member,required TResult Function( PrincipalStaffPendingRefresh value)  staffPendingRefresh,required TResult Function( PrincipalMemberPendingRefresh value)  memberPendingRefresh,required TResult Function( PrincipalNotLinked value)  notLinked,}){
final _that = this;
switch (_that) {
case PrincipalSignedOut():
return signedOut(_that);case PrincipalStaff():
return staff(_that);case PrincipalMember():
return member(_that);case PrincipalStaffPendingRefresh():
return staffPendingRefresh(_that);case PrincipalMemberPendingRefresh():
return memberPendingRefresh(_that);case PrincipalNotLinked():
return notLinked(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PrincipalSignedOut value)?  signedOut,TResult? Function( PrincipalStaff value)?  staff,TResult? Function( PrincipalMember value)?  member,TResult? Function( PrincipalStaffPendingRefresh value)?  staffPendingRefresh,TResult? Function( PrincipalMemberPendingRefresh value)?  memberPendingRefresh,TResult? Function( PrincipalNotLinked value)?  notLinked,}){
final _that = this;
switch (_that) {
case PrincipalSignedOut() when signedOut != null:
return signedOut(_that);case PrincipalStaff() when staff != null:
return staff(_that);case PrincipalMember() when member != null:
return member(_that);case PrincipalStaffPendingRefresh() when staffPendingRefresh != null:
return staffPendingRefresh(_that);case PrincipalMemberPendingRefresh() when memberPendingRefresh != null:
return memberPendingRefresh(_that);case PrincipalNotLinked() when notLinked != null:
return notLinked(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  signedOut,TResult Function( AppClaims claims)?  staff,TResult Function( AppClaims claims)?  member,TResult Function( CurrentStaff staff)?  staffPendingRefresh,TResult Function( CurrentMember member)?  memberPendingRefresh,TResult Function()?  notLinked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PrincipalSignedOut() when signedOut != null:
return signedOut();case PrincipalStaff() when staff != null:
return staff(_that.claims);case PrincipalMember() when member != null:
return member(_that.claims);case PrincipalStaffPendingRefresh() when staffPendingRefresh != null:
return staffPendingRefresh(_that.staff);case PrincipalMemberPendingRefresh() when memberPendingRefresh != null:
return memberPendingRefresh(_that.member);case PrincipalNotLinked() when notLinked != null:
return notLinked();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  signedOut,required TResult Function( AppClaims claims)  staff,required TResult Function( AppClaims claims)  member,required TResult Function( CurrentStaff staff)  staffPendingRefresh,required TResult Function( CurrentMember member)  memberPendingRefresh,required TResult Function()  notLinked,}) {final _that = this;
switch (_that) {
case PrincipalSignedOut():
return signedOut();case PrincipalStaff():
return staff(_that.claims);case PrincipalMember():
return member(_that.claims);case PrincipalStaffPendingRefresh():
return staffPendingRefresh(_that.staff);case PrincipalMemberPendingRefresh():
return memberPendingRefresh(_that.member);case PrincipalNotLinked():
return notLinked();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  signedOut,TResult? Function( AppClaims claims)?  staff,TResult? Function( AppClaims claims)?  member,TResult? Function( CurrentStaff staff)?  staffPendingRefresh,TResult? Function( CurrentMember member)?  memberPendingRefresh,TResult? Function()?  notLinked,}) {final _that = this;
switch (_that) {
case PrincipalSignedOut() when signedOut != null:
return signedOut();case PrincipalStaff() when staff != null:
return staff(_that.claims);case PrincipalMember() when member != null:
return member(_that.claims);case PrincipalStaffPendingRefresh() when staffPendingRefresh != null:
return staffPendingRefresh(_that.staff);case PrincipalMemberPendingRefresh() when memberPendingRefresh != null:
return memberPendingRefresh(_that.member);case PrincipalNotLinked() when notLinked != null:
return notLinked();case _:
  return null;

}
}

}

/// @nodoc


class PrincipalSignedOut implements Principal {
  const PrincipalSignedOut();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalSignedOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Principal.signedOut()';
}


}




/// @nodoc


class PrincipalStaff implements Principal {
  const PrincipalStaff(this.claims);
  

 final  AppClaims claims;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrincipalStaffCopyWith<PrincipalStaff> get copyWith => _$PrincipalStaffCopyWithImpl<PrincipalStaff>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalStaff&&(identical(other.claims, claims) || other.claims == claims));
}


@override
int get hashCode => Object.hash(runtimeType,claims);

@override
String toString() {
  return 'Principal.staff(claims: $claims)';
}


}

/// @nodoc
abstract mixin class $PrincipalStaffCopyWith<$Res> implements $PrincipalCopyWith<$Res> {
  factory $PrincipalStaffCopyWith(PrincipalStaff value, $Res Function(PrincipalStaff) _then) = _$PrincipalStaffCopyWithImpl;
@useResult
$Res call({
 AppClaims claims
});




}
/// @nodoc
class _$PrincipalStaffCopyWithImpl<$Res>
    implements $PrincipalStaffCopyWith<$Res> {
  _$PrincipalStaffCopyWithImpl(this._self, this._then);

  final PrincipalStaff _self;
  final $Res Function(PrincipalStaff) _then;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? claims = null,}) {
  return _then(PrincipalStaff(
null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as AppClaims,
  ));
}


}

/// @nodoc


class PrincipalMember implements Principal {
  const PrincipalMember(this.claims);
  

 final  AppClaims claims;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrincipalMemberCopyWith<PrincipalMember> get copyWith => _$PrincipalMemberCopyWithImpl<PrincipalMember>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalMember&&(identical(other.claims, claims) || other.claims == claims));
}


@override
int get hashCode => Object.hash(runtimeType,claims);

@override
String toString() {
  return 'Principal.member(claims: $claims)';
}


}

/// @nodoc
abstract mixin class $PrincipalMemberCopyWith<$Res> implements $PrincipalCopyWith<$Res> {
  factory $PrincipalMemberCopyWith(PrincipalMember value, $Res Function(PrincipalMember) _then) = _$PrincipalMemberCopyWithImpl;
@useResult
$Res call({
 AppClaims claims
});




}
/// @nodoc
class _$PrincipalMemberCopyWithImpl<$Res>
    implements $PrincipalMemberCopyWith<$Res> {
  _$PrincipalMemberCopyWithImpl(this._self, this._then);

  final PrincipalMember _self;
  final $Res Function(PrincipalMember) _then;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? claims = null,}) {
  return _then(PrincipalMember(
null == claims ? _self.claims : claims // ignore: cast_nullable_to_non_nullable
as AppClaims,
  ));
}


}

/// @nodoc


class PrincipalStaffPendingRefresh implements Principal {
  const PrincipalStaffPendingRefresh(this.staff);
  

 final  CurrentStaff staff;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrincipalStaffPendingRefreshCopyWith<PrincipalStaffPendingRefresh> get copyWith => _$PrincipalStaffPendingRefreshCopyWithImpl<PrincipalStaffPendingRefresh>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalStaffPendingRefresh&&(identical(other.staff, staff) || other.staff == staff));
}


@override
int get hashCode => Object.hash(runtimeType,staff);

@override
String toString() {
  return 'Principal.staffPendingRefresh(staff: $staff)';
}


}

/// @nodoc
abstract mixin class $PrincipalStaffPendingRefreshCopyWith<$Res> implements $PrincipalCopyWith<$Res> {
  factory $PrincipalStaffPendingRefreshCopyWith(PrincipalStaffPendingRefresh value, $Res Function(PrincipalStaffPendingRefresh) _then) = _$PrincipalStaffPendingRefreshCopyWithImpl;
@useResult
$Res call({
 CurrentStaff staff
});


$CurrentStaffCopyWith<$Res> get staff;

}
/// @nodoc
class _$PrincipalStaffPendingRefreshCopyWithImpl<$Res>
    implements $PrincipalStaffPendingRefreshCopyWith<$Res> {
  _$PrincipalStaffPendingRefreshCopyWithImpl(this._self, this._then);

  final PrincipalStaffPendingRefresh _self;
  final $Res Function(PrincipalStaffPendingRefresh) _then;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? staff = null,}) {
  return _then(PrincipalStaffPendingRefresh(
null == staff ? _self.staff : staff // ignore: cast_nullable_to_non_nullable
as CurrentStaff,
  ));
}

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentStaffCopyWith<$Res> get staff {
  
  return $CurrentStaffCopyWith<$Res>(_self.staff, (value) {
    return _then(_self.copyWith(staff: value));
  });
}
}

/// @nodoc


class PrincipalMemberPendingRefresh implements Principal {
  const PrincipalMemberPendingRefresh(this.member);
  

 final  CurrentMember member;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrincipalMemberPendingRefreshCopyWith<PrincipalMemberPendingRefresh> get copyWith => _$PrincipalMemberPendingRefreshCopyWithImpl<PrincipalMemberPendingRefresh>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalMemberPendingRefresh&&(identical(other.member, member) || other.member == member));
}


@override
int get hashCode => Object.hash(runtimeType,member);

@override
String toString() {
  return 'Principal.memberPendingRefresh(member: $member)';
}


}

/// @nodoc
abstract mixin class $PrincipalMemberPendingRefreshCopyWith<$Res> implements $PrincipalCopyWith<$Res> {
  factory $PrincipalMemberPendingRefreshCopyWith(PrincipalMemberPendingRefresh value, $Res Function(PrincipalMemberPendingRefresh) _then) = _$PrincipalMemberPendingRefreshCopyWithImpl;
@useResult
$Res call({
 CurrentMember member
});


$CurrentMemberCopyWith<$Res> get member;

}
/// @nodoc
class _$PrincipalMemberPendingRefreshCopyWithImpl<$Res>
    implements $PrincipalMemberPendingRefreshCopyWith<$Res> {
  _$PrincipalMemberPendingRefreshCopyWithImpl(this._self, this._then);

  final PrincipalMemberPendingRefresh _self;
  final $Res Function(PrincipalMemberPendingRefresh) _then;

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? member = null,}) {
  return _then(PrincipalMemberPendingRefresh(
null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as CurrentMember,
  ));
}

/// Create a copy of Principal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentMemberCopyWith<$Res> get member {
  
  return $CurrentMemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}

/// @nodoc


class PrincipalNotLinked implements Principal {
  const PrincipalNotLinked();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrincipalNotLinked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Principal.notLinked()';
}


}




/// @nodoc
mixin _$LinkOutcome {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LinkOutcome()';
}


}

/// @nodoc
class $LinkOutcomeCopyWith<$Res>  {
$LinkOutcomeCopyWith(LinkOutcome _, $Res Function(LinkOutcome) __);
}


/// Adds pattern-matching-related methods to [LinkOutcome].
extension LinkOutcomePatterns on LinkOutcome {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LinkOutcomeLinked value)?  linked,TResult Function( LinkOutcomeNotLinked value)?  notLinked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LinkOutcomeLinked() when linked != null:
return linked(_that);case LinkOutcomeNotLinked() when notLinked != null:
return notLinked(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LinkOutcomeLinked value)  linked,required TResult Function( LinkOutcomeNotLinked value)  notLinked,}){
final _that = this;
switch (_that) {
case LinkOutcomeLinked():
return linked(_that);case LinkOutcomeNotLinked():
return notLinked(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LinkOutcomeLinked value)?  linked,TResult? Function( LinkOutcomeNotLinked value)?  notLinked,}){
final _that = this;
switch (_that) {
case LinkOutcomeLinked() when linked != null:
return linked(_that);case LinkOutcomeNotLinked() when notLinked != null:
return notLinked(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String principalId)?  linked,TResult Function( LinkFailure reason)?  notLinked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LinkOutcomeLinked() when linked != null:
return linked(_that.principalId);case LinkOutcomeNotLinked() when notLinked != null:
return notLinked(_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String principalId)  linked,required TResult Function( LinkFailure reason)  notLinked,}) {final _that = this;
switch (_that) {
case LinkOutcomeLinked():
return linked(_that.principalId);case LinkOutcomeNotLinked():
return notLinked(_that.reason);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String principalId)?  linked,TResult? Function( LinkFailure reason)?  notLinked,}) {final _that = this;
switch (_that) {
case LinkOutcomeLinked() when linked != null:
return linked(_that.principalId);case LinkOutcomeNotLinked() when notLinked != null:
return notLinked(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class LinkOutcomeLinked implements LinkOutcome {
  const LinkOutcomeLinked(this.principalId);
  

 final  String principalId;

/// Create a copy of LinkOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkOutcomeLinkedCopyWith<LinkOutcomeLinked> get copyWith => _$LinkOutcomeLinkedCopyWithImpl<LinkOutcomeLinked>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkOutcomeLinked&&(identical(other.principalId, principalId) || other.principalId == principalId));
}


@override
int get hashCode => Object.hash(runtimeType,principalId);

@override
String toString() {
  return 'LinkOutcome.linked(principalId: $principalId)';
}


}

/// @nodoc
abstract mixin class $LinkOutcomeLinkedCopyWith<$Res> implements $LinkOutcomeCopyWith<$Res> {
  factory $LinkOutcomeLinkedCopyWith(LinkOutcomeLinked value, $Res Function(LinkOutcomeLinked) _then) = _$LinkOutcomeLinkedCopyWithImpl;
@useResult
$Res call({
 String principalId
});




}
/// @nodoc
class _$LinkOutcomeLinkedCopyWithImpl<$Res>
    implements $LinkOutcomeLinkedCopyWith<$Res> {
  _$LinkOutcomeLinkedCopyWithImpl(this._self, this._then);

  final LinkOutcomeLinked _self;
  final $Res Function(LinkOutcomeLinked) _then;

/// Create a copy of LinkOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? principalId = null,}) {
  return _then(LinkOutcomeLinked(
null == principalId ? _self.principalId : principalId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LinkOutcomeNotLinked implements LinkOutcome {
  const LinkOutcomeNotLinked(this.reason);
  

 final  LinkFailure reason;

/// Create a copy of LinkOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkOutcomeNotLinkedCopyWith<LinkOutcomeNotLinked> get copyWith => _$LinkOutcomeNotLinkedCopyWithImpl<LinkOutcomeNotLinked>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkOutcomeNotLinked&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'LinkOutcome.notLinked(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $LinkOutcomeNotLinkedCopyWith<$Res> implements $LinkOutcomeCopyWith<$Res> {
  factory $LinkOutcomeNotLinkedCopyWith(LinkOutcomeNotLinked value, $Res Function(LinkOutcomeNotLinked) _then) = _$LinkOutcomeNotLinkedCopyWithImpl;
@useResult
$Res call({
 LinkFailure reason
});




}
/// @nodoc
class _$LinkOutcomeNotLinkedCopyWithImpl<$Res>
    implements $LinkOutcomeNotLinkedCopyWith<$Res> {
  _$LinkOutcomeNotLinkedCopyWithImpl(this._self, this._then);

  final LinkOutcomeNotLinked _self;
  final $Res Function(LinkOutcomeNotLinked) _then;

/// Create a copy of LinkOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(LinkOutcomeNotLinked(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as LinkFailure,
  ));
}


}

// dart format on
