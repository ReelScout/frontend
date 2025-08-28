import 'package:frontend/model/actor.dart';
import 'package:frontend/model/director.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/request/content_request_dto.g.dart';

@JsonSerializable()
class ContentRequestDto {
  ContentRequestDto({
    required this.title,
    required this.description,
    required this.contentType,
    required this.actors,
    required this.directors,
    this.base64Image,
    this.trailerUrl,
  });

  final String title;
  final String description;
  final String contentType;
  final List<Actor> actors;
  final List<Director> directors;
  final String? base64Image;
  final String? trailerUrl;

  factory ContentRequestDto.fromJson(Map<String, dynamic> json) => _$ContentRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentRequestDtoToJson(this);
}