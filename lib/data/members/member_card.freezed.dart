// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberCard {

 String get id; String get orgId; String get memberId;/// Upper-case hex, 8 to 20 characters -- the column's own check.
 String get cardUid; String? get assignedBy; DateTime get assignedAt; DateTime? get revokedAt; String? get revokedBy; String? get revokeReason;
/// Create a copy of MemberCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCardCopyWith<MemberCard> get copyWith => _$MemberCardCopyWithImpl<MemberCard>(this as MemberCard, _$identity);

  /// Serializes this MemberCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberCard&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.cardUid, cardUid) || other.cardUid == cardUid)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.revokedBy, revokedBy) || other.revokedBy == revokedBy)&&(identical(other.revokeReason, revokeReason) || other.revokeReason == revokeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,memberId,cardUid,assignedBy,assignedAt,revokedAt,revokedBy,revokeReason);

@override
String toString() {
  return 'MemberCard(id: $id, orgId: $orgId, memberId: $memberId, cardUid: $cardUid, assignedBy: $assignedBy, assignedAt: $assignedAt, revokedAt: $revokedAt, revokedBy: $revokedBy, revokeReason: $revokeReason)';
}


}

/// @nodoc
abstract mixin class $MemberCardCopyWith<$Res>  {
  factory $MemberCardCopyWith(MemberCard value, $Res Function(MemberCard) _then) = _$MemberCardCopyWithImpl;
@useResult
$Res call({
 String id, String orgId, String memberId, String cardUid, String? assignedBy, DateTime assignedAt, DateTime? revokedAt, String? revokedBy, String? revokeReason
});




}
/// @nodoc
class _$MemberCardCopyWithImpl<$Res>
    implements $MemberCardCopyWith<$Res> {
  _$MemberCardCopyWithImpl(this._self, this._then);

  final MemberCard _self;
  final $Res Function(MemberCard) _then;

/// Create a copy of MemberCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? memberId = null,Object? cardUid = null,Object? assignedBy = freezed,Object? assignedAt = null,Object? revokedAt = freezed,Object? revokedBy = freezed,Object? revokeReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,cardUid: null == cardUid ? _self.cardUid : cardUid // ignore: cast_nullable_to_non_nullable
as String,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedBy: freezed == revokedBy ? _self.revokedBy : revokedBy // ignore: cast_nullable_to_non_nullable
as String?,revokeReason: freezed == revokeReason ? _self.revokeReason : revokeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberCard].
extension MemberCardPatterns on MemberCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberCard() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberCard value)  $default,){
final _that = this;
switch (_that) {
case _MemberCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberCard value)?  $default,){
final _that = this;
switch (_that) {
case _MemberCard() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orgId,  String memberId,  String cardUid,  String? assignedBy,  DateTime assignedAt,  DateTime? revokedAt,  String? revokedBy,  String? revokeReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberCard() when $default != null:
return $default(_that.id,_that.orgId,_that.memberId,_that.cardUid,_that.assignedBy,_that.assignedAt,_that.revokedAt,_that.revokedBy,_that.revokeReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orgId,  String memberId,  String cardUid,  String? assignedBy,  DateTime assignedAt,  DateTime? revokedAt,  String? revokedBy,  String? revokeReason)  $default,) {final _that = this;
switch (_that) {
case _MemberCard():
return $default(_that.id,_that.orgId,_that.memberId,_that.cardUid,_that.assignedBy,_that.assignedAt,_that.revokedAt,_that.revokedBy,_that.revokeReason);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orgId,  String memberId,  String cardUid,  String? assignedBy,  DateTime assignedAt,  DateTime? revokedAt,  String? revokedBy,  String? revokeReason)?  $default,) {final _that = this;
switch (_that) {
case _MemberCard() when $default != null:
return $default(_that.id,_that.orgId,_that.memberId,_that.cardUid,_that.assignedBy,_that.assignedAt,_that.revokedAt,_that.revokedBy,_that.revokeReason);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MemberCard extends MemberCard {
  const _MemberCard({required this.id, required this.orgId, required this.memberId, required this.cardUid, this.assignedBy, required this.assignedAt, this.revokedAt, this.revokedBy, this.revokeReason}): super._();
  factory _MemberCard.fromJson(Map<String, dynamic> json) => _$MemberCardFromJson(json);

@override final  String id;
@override final  String orgId;
@override final  String memberId;
/// Upper-case hex, 8 to 20 characters -- the column's own check.
@override final  String cardUid;
@override final  String? assignedBy;
@override final  DateTime assignedAt;
@override final  DateTime? revokedAt;
@override final  String? revokedBy;
@override final  String? revokeReason;

/// Create a copy of MemberCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCardCopyWith<_MemberCard> get copyWith => __$MemberCardCopyWithImpl<_MemberCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberCard&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.cardUid, cardUid) || other.cardUid == cardUid)&&(identical(other.assignedBy, assignedBy) || other.assignedBy == assignedBy)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.revokedBy, revokedBy) || other.revokedBy == revokedBy)&&(identical(other.revokeReason, revokeReason) || other.revokeReason == revokeReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,memberId,cardUid,assignedBy,assignedAt,revokedAt,revokedBy,revokeReason);

@override
String toString() {
  return 'MemberCard(id: $id, orgId: $orgId, memberId: $memberId, cardUid: $cardUid, assignedBy: $assignedBy, assignedAt: $assignedAt, revokedAt: $revokedAt, revokedBy: $revokedBy, revokeReason: $revokeReason)';
}


}

/// @nodoc
abstract mixin class _$MemberCardCopyWith<$Res> implements $MemberCardCopyWith<$Res> {
  factory _$MemberCardCopyWith(_MemberCard value, $Res Function(_MemberCard) _then) = __$MemberCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String orgId, String memberId, String cardUid, String? assignedBy, DateTime assignedAt, DateTime? revokedAt, String? revokedBy, String? revokeReason
});




}
/// @nodoc
class __$MemberCardCopyWithImpl<$Res>
    implements _$MemberCardCopyWith<$Res> {
  __$MemberCardCopyWithImpl(this._self, this._then);

  final _MemberCard _self;
  final $Res Function(_MemberCard) _then;

/// Create a copy of MemberCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? memberId = null,Object? cardUid = null,Object? assignedBy = freezed,Object? assignedAt = null,Object? revokedAt = freezed,Object? revokedBy = freezed,Object? revokeReason = freezed,}) {
  return _then(_MemberCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,cardUid: null == cardUid ? _self.cardUid : cardUid // ignore: cast_nullable_to_non_nullable
as String,assignedBy: freezed == assignedBy ? _self.assignedBy : assignedBy // ignore: cast_nullable_to_non_nullable
as String?,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revokedBy: freezed == revokedBy ? _self.revokedBy : revokedBy // ignore: cast_nullable_to_non_nullable
as String?,revokeReason: freezed == revokeReason ? _self.revokeReason : revokeReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
