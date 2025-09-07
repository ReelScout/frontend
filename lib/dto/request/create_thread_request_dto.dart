import 'package:json_annotation/json_annotation.dart';

part '../generated/request/create_thread_request_dto.g.dart';

@JsonSerializable()
class CreateThreadRequestDto {
  CreateThreadRequestDto({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  factory CreateThreadRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateThreadRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateThreadRequestDtoToJson(this);
}

