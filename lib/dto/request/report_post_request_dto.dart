import 'package:json_annotation/json_annotation.dart';

part '../generated/request/report_post_request_dto.g.dart';

@JsonSerializable()
class ReportPostRequestDto {
  ReportPostRequestDto({required this.reason});

  final String reason;

  factory ReportPostRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReportPostRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportPostRequestDtoToJson(this);
}

