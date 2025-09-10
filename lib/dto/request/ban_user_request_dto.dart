import 'package:json_annotation/json_annotation.dart';

part '../generated/request/ban_user_request_dto.g.dart';

@JsonSerializable()
class BanUserRequestDto {
  BanUserRequestDto({this.reason});

  final String? reason;

  factory BanUserRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BanUserRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BanUserRequestDtoToJson(this);
}

