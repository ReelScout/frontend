import 'package:json_annotation/json_annotation.dart';

part '../generated/request/create_post_request_dto.g.dart';

@JsonSerializable()
class CreatePostRequestDto {
  CreatePostRequestDto({
    required this.body,
    this.parentId,
  });

  final String body;
  final int? parentId;

  factory CreatePostRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostRequestDtoToJson(this);
}

