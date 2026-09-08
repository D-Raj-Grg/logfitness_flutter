// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_with_collector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentWithCollector {

 Payment get payment;/// Null when `collected_by` is null, and also when RLS hides the staff
/// row from this caller. The two are indistinguishable here, which is
/// correct -- a name the policy will not disclose must not be inferable
/// from its absence being reported differently.
 String? get collectorName;
/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentWithCollectorCopyWith<PaymentWithCollector> get copyWith => _$PaymentWithCollectorCopyWithImpl<PaymentWithCollector>(this as PaymentWithCollector, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentWithCollector&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}


@override
int get hashCode => Object.hash(runtimeType,payment,collectorName);

@override
String toString() {
  return 'PaymentWithCollector(payment: $payment, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class $PaymentWithCollectorCopyWith<$Res>  {
  factory $PaymentWithCollectorCopyWith(PaymentWithCollector value, $Res Function(PaymentWithCollector) _then) = _$PaymentWithCollectorCopyWithImpl;
@useResult
$Res call({
 Payment payment, String? collectorName
});


$PaymentCopyWith<$Res> get payment;

}
/// @nodoc
class _$PaymentWithCollectorCopyWithImpl<$Res>
    implements $PaymentWithCollectorCopyWith<$Res> {
  _$PaymentWithCollectorCopyWithImpl(this._self, this._then);

  final PaymentWithCollector _self;
  final $Res Function(PaymentWithCollector) _then;

/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payment = null,Object? collectorName = freezed,}) {
  return _then(_self.copyWith(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,collectorName: freezed == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentWithCollector].
extension PaymentWithCollectorPatterns on PaymentWithCollector {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentWithCollector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentWithCollector() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentWithCollector value)  $default,){
final _that = this;
switch (_that) {
case _PaymentWithCollector():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentWithCollector value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentWithCollector() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Payment payment,  String? collectorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentWithCollector() when $default != null:
return $default(_that.payment,_that.collectorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Payment payment,  String? collectorName)  $default,) {final _that = this;
switch (_that) {
case _PaymentWithCollector():
return $default(_that.payment,_that.collectorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Payment payment,  String? collectorName)?  $default,) {final _that = this;
switch (_that) {
case _PaymentWithCollector() when $default != null:
return $default(_that.payment,_that.collectorName);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentWithCollector implements PaymentWithCollector {
  const _PaymentWithCollector({required this.payment, this.collectorName});
  

@override final  Payment payment;
/// Null when `collected_by` is null, and also when RLS hides the staff
/// row from this caller. The two are indistinguishable here, which is
/// correct -- a name the policy will not disclose must not be inferable
/// from its absence being reported differently.
@override final  String? collectorName;

/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentWithCollectorCopyWith<_PaymentWithCollector> get copyWith => __$PaymentWithCollectorCopyWithImpl<_PaymentWithCollector>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentWithCollector&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}


@override
int get hashCode => Object.hash(runtimeType,payment,collectorName);

@override
String toString() {
  return 'PaymentWithCollector(payment: $payment, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class _$PaymentWithCollectorCopyWith<$Res> implements $PaymentWithCollectorCopyWith<$Res> {
  factory _$PaymentWithCollectorCopyWith(_PaymentWithCollector value, $Res Function(_PaymentWithCollector) _then) = __$PaymentWithCollectorCopyWithImpl;
@override @useResult
$Res call({
 Payment payment, String? collectorName
});


@override $PaymentCopyWith<$Res> get payment;

}
/// @nodoc
class __$PaymentWithCollectorCopyWithImpl<$Res>
    implements _$PaymentWithCollectorCopyWith<$Res> {
  __$PaymentWithCollectorCopyWithImpl(this._self, this._then);

  final _PaymentWithCollector _self;
  final $Res Function(_PaymentWithCollector) _then;

/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? collectorName = freezed,}) {
  return _then(_PaymentWithCollector(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as Payment,collectorName: freezed == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PaymentWithCollector
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentCopyWith<$Res> get payment {
  
  return $PaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

// dart format on
