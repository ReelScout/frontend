import 'package:json_annotation/json_annotation.dart';

part '../generated/response/forum_post_response_dto.g.dart';

@JsonSerializable()
class ForumPostResponseDto {
  ForumPostResponseDto({
    required this.id,
    required this.threadId,
    required this.authorUsername,
    required this.body,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int threadId;
  final String authorUsername;
  final String body;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ForumPostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForumPostResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ForumPostResponseDtoToJson(this);
}

