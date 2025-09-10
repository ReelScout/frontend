// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/suspend_user_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuspendUserRequestDto _$SuspendUserRequestDtoFromJson(
  Map<String, dynamic> json,
) => SuspendUserRequestDto(
  until: DateTime.parse(json['until'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$SuspendUserRequestDtoToJson(
  SuspendUserRequestDto instance,
) => <String, dynamic>{
  'until': instance.until.toIso8601String(),
  'reason': instance.reason,
};
