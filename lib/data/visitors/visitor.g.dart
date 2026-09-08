// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Visitor _$VisitorFromJson(Map<String, dynamic> json) => _Visitor(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  branchId: json['branch_id'] as String,
  kind: $enumDecode(_$VisitorKindEnumMap, json['kind']),
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  visitedOn: const PlainDateConverter().fromJson(json['visited_on'] as String),
  note: json['note'] as String?,
  interestedPlanId: json['interested_plan_id'] as String?,
  status: $enumDecode(_$VisitorStatusEnumMap, json['status']),
  convertedMemberId: json['converted_member_id'] as String?,
  convertedAt: json['converted_at'] == null
      ? null
      : DateTime.parse(json['converted_at'] as String),
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$VisitorToJson(_Visitor instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': instance.branchId,
  'kind': _$VisitorKindEnumMap[instance.kind]!,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'visited_on': const PlainDateConverter().toJson(instance.visitedOn),
  'note': ?instance.note,
  'interested_plan_id': ?instance.interestedPlanId,
  'status': _$VisitorStatusEnumMap[instance.status]!,
  'converted_member_id': ?instance.convertedMemberId,
  'converted_at': ?instance.convertedAt?.toIso8601String(),
  'created_by': ?instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$VisitorKindEnumMap = {
  VisitorKind.enquiry: 'enquiry',
  VisitorKind.guest: 'guest',
};

const _$VisitorStatusEnumMap = {
  VisitorStatus.isNew: 'new',
  VisitorStatus.contacted: 'contacted',
  VisitorStatus.converted: 'converted',
  VisitorStatus.lost: 'lost',
};
