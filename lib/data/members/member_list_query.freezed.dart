// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_list_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MemberListQuery {

/// Matches a phone prefix, a member-code prefix, or any part of the name
/// -- the three things a front desk is ever told. Trimmed by the
/// repository, not here.
 String get q; MemberListFilter? get status;/// One-based, like the console's. Page zero is not a thing the URL can
/// express.
 int get page; int get pageSize;
/// Create a copy of MemberListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberListQueryCopyWith<MemberListQuery> get copyWith => _$MemberListQueryCopyWithImpl<MemberListQuery>(this as MemberListQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberListQuery&&(identical(other.q, q) || other.q == q)&&(identical(other.status, status) || other.status == status)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,q,status,page,pageSize);

@override
String toString() {
  return 'MemberListQuery(q: $q, status: $status, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $MemberListQueryCopyWith<$Res>  {
  factory $MemberListQueryCopyWith(MemberListQuery value, $Res Function(MemberListQuery) _then) = _$MemberListQueryCopyWithImpl;
@useResult
$Res call({
 String q, MemberListFilter? status, int page, int pageSize
});




}
/// @nodoc
class _$MemberListQueryCopyWithImpl<$Res>
    implements $MemberListQueryCopyWith<$Res> {
  _$MemberListQueryCopyWithImpl(this._self, this._then);

  final MemberListQuery _self;
  final $Res Function(MemberListQuery) _then;

/// Create a copy of MemberListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? q = null,Object? status = freezed,Object? page = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberListFilter?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberListQuery].
extension MemberListQueryPatterns on MemberListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberListQuery value)  $default,){
final _that = this;
switch (_that) {
case _MemberListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _MemberListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String q,  MemberListFilter? status,  int page,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberListQuery() when $default != null:
return $default(_that.q,_that.status,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String q,  MemberListFilter? status,  int page,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _MemberListQuery():
return $default(_that.q,_that.status,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String q,  MemberListFilter? status,  int page,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _MemberListQuery() when $default != null:
return $default(_that.q,_that.status,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _MemberListQuery implements MemberListQuery {
  const _MemberListQuery({this.q = '', this.status, this.page = 1, this.pageSize = defaultMemberPageSize});
  

/// Matches a phone prefix, a member-code prefix, or any part of the name
/// -- the three things a front desk is ever told. Trimmed by the
/// repository, not here.
@override@JsonKey() final  String q;
@override final  MemberListFilter? status;
/// One-based, like the console's. Page zero is not a thing the URL can
/// express.
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;

/// Create a copy of MemberListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberListQueryCopyWith<_MemberListQuery> get copyWith => __$MemberListQueryCopyWithImpl<_MemberListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberListQuery&&(identical(other.q, q) || other.q == q)&&(identical(other.status, status) || other.status == status)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,q,status,page,pageSize);

@override
String toString() {
  return 'MemberListQuery(q: $q, status: $status, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$MemberListQueryCopyWith<$Res> implements $MemberListQueryCopyWith<$Res> {
  factory _$MemberListQueryCopyWith(_MemberListQuery value, $Res Function(_MemberListQuery) _then) = __$MemberListQueryCopyWithImpl;
@override @useResult
$Res call({
 String q, MemberListFilter? status, int page, int pageSize
});




}
/// @nodoc
class __$MemberListQueryCopyWithImpl<$Res>
    implements _$MemberListQueryCopyWith<$Res> {
  __$MemberListQueryCopyWithImpl(this._self, this._then);

  final _MemberListQuery _self;
  final $Res Function(_MemberListQuery) _then;

/// Create a copy of MemberListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? q = null,Object? status = freezed,Object? page = null,Object? pageSize = null,}) {
  return _then(_MemberListQuery(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberListFilter?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MemberListResult {

 List<MemberOverview> get rows;/// The count of rows matching the filters, ignoring the page window --
/// what the pager needs to know how many pages there are.
 int get total; int get page; int get pageSize;
/// Create a copy of MemberListResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberListResultCopyWith<MemberListResult> get copyWith => _$MemberListResultCopyWithImpl<MemberListResult>(this as MemberListResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberListResult&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rows),total,page,pageSize);

@override
String toString() {
  return 'MemberListResult(rows: $rows, total: $total, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $MemberListResultCopyWith<$Res>  {
  factory $MemberListResultCopyWith(MemberListResult value, $Res Function(MemberListResult) _then) = _$MemberListResultCopyWithImpl;
@useResult
$Res call({
 List<MemberOverview> rows, int total, int page, int pageSize
});




}
/// @nodoc
class _$MemberListResultCopyWithImpl<$Res>
    implements $MemberListResultCopyWith<$Res> {
  _$MemberListResultCopyWithImpl(this._self, this._then);

  final MemberListResult _self;
  final $Res Function(MemberListResult) _then;

/// Create a copy of MemberListResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<MemberOverview>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberListResult].
extension MemberListResultPatterns on MemberListResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberListResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberListResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberListResult value)  $default,){
final _that = this;
switch (_that) {
case _MemberListResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberListResult value)?  $default,){
final _that = this;
switch (_that) {
case _MemberListResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MemberOverview> rows,  int total,  int page,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberListResult() when $default != null:
return $default(_that.rows,_that.total,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MemberOverview> rows,  int total,  int page,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _MemberListResult():
return $default(_that.rows,_that.total,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MemberOverview> rows,  int total,  int page,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _MemberListResult() when $default != null:
return $default(_that.rows,_that.total,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _MemberListResult implements MemberListResult {
  const _MemberListResult({required final  List<MemberOverview> rows, required this.total, required this.page, required this.pageSize}): _rows = rows;
  

 final  List<MemberOverview> _rows;
@override List<MemberOverview> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

/// The count of rows matching the filters, ignoring the page window --
/// what the pager needs to know how many pages there are.
@override final  int total;
@override final  int page;
@override final  int pageSize;

/// Create a copy of MemberListResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberListResultCopyWith<_MemberListResult> get copyWith => __$MemberListResultCopyWithImpl<_MemberListResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberListResult&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),total,page,pageSize);

@override
String toString() {
  return 'MemberListResult(rows: $rows, total: $total, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$MemberListResultCopyWith<$Res> implements $MemberListResultCopyWith<$Res> {
  factory _$MemberListResultCopyWith(_MemberListResult value, $Res Function(_MemberListResult) _then) = __$MemberListResultCopyWithImpl;
@override @useResult
$Res call({
 List<MemberOverview> rows, int total, int page, int pageSize
});




}
/// @nodoc
class __$MemberListResultCopyWithImpl<$Res>
    implements _$MemberListResultCopyWith<$Res> {
  __$MemberListResultCopyWithImpl(this._self, this._then);

  final _MemberListResult _self;
  final $Res Function(_MemberListResult) _then;

/// Create a copy of MemberListResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_MemberListResult(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<MemberOverview>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
