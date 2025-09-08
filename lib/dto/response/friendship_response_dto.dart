import 'package:frontend/model/friendship_status.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/friendship_response_dto.g.dart';

@JsonSerializable()
class FriendshipResponseDto {
  const FriendshipResponseDto({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FriendshipResponseDto.fromJson(Map<String, dynamic> json) => _$FriendshipResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FriendshipResponseDtoToJson(this);
}

