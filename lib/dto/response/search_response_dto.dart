import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/search_response_dto.g.dart';

@JsonSerializable()
class SearchResponseDto {
  const SearchResponseDto({
    required this.users,
    required this.contents
  });

  final List<UserResponseDto> users;
  final List<ContentResponseDto> contents;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) => _$SearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseDtoToJson(this);
}