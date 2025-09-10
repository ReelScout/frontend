import 'package:json_annotation/json_annotation.dart';

part '../generated/request/suspend_user_request_dto.g.dart';

@JsonSerializable()
class SuspendUserRequestDto {
  SuspendUserRequestDto({required this.until, this.reason});

  final DateTime until;
  final String? reason;

  factory SuspendUserRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SuspendUserRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuspendUserRequestDtoToJson(this);
}

