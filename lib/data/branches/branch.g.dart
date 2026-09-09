// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Branch _$BranchFromJson(Map<String, dynamic> json) => _Branch(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  name: json['name'] as String,
  status: $enumDecode(_$BranchStatusEnumMap, json['status']),
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  opensAt: json['opens_at'] as String?,
  closesAt: json['closes_at'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BranchToJson(_Branch instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'name': instance.name,
  'status': _$BranchStatusEnumMap[instance.status]!,
  'address': ?instance.address,
  'phone': ?instance.phone,
  'opens_at': ?instance.opensAt,
  'closes_at': ?instance.closesAt,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$BranchStatusEnumMap = {
  BranchStatus.active: 'active',
  BranchStatus.inactive: 'inactive',
};
