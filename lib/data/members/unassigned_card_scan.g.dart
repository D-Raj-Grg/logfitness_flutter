// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unassigned_card_scan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnassignedCardScan _$UnassignedCardScanFromJson(Map<String, dynamic> json) =>
    _UnassignedCardScan(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      branchId: json['branch_id'] as String?,
      deviceId: json['device_id'] as String?,
      cardUid: json['card_uid'] as String,
      firstSeenAt: json['first_seen_at'] == null
          ? null
          : DateTime.parse(json['first_seen_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      scanCount: (json['scan_count'] as num?)?.toInt() ?? 1,
      deviceName: _readDeviceName(json, 'device_name') as String?,
    );

Map<String, dynamic> _$UnassignedCardScanToJson(_UnassignedCardScan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'branch_id': ?instance.branchId,
      'device_id': ?instance.deviceId,
      'card_uid': instance.cardUid,
      'first_seen_at': ?instance.firstSeenAt?.toIso8601String(),
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'scan_count': instance.scanCount,
      'device_name': ?instance.deviceName,
    };
