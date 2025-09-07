import 'package:json_annotation/json_annotation.dart';

part '../generated/response/forum_thread_response_dto.g.dart';

@JsonSerializable()
class ForumThreadResponseDto {
  ForumThreadResponseDto({
    required this.id,
    required this.contentId,
    required this.title,
    required this.createdByUsername,
    required this.createdAt,
    required this.updatedAt,
    required this.postCount,
  });

  final int id;
  final int contentId;
  final String title;
  final String createdByUsername;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int postCount;

  factory ForumThreadResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForumThreadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ForumThreadResponseDtoToJson(this);
}

