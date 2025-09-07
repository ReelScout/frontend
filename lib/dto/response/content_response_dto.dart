import 'package:json_annotation/json_annotation.dart';

import 'package:frontend/model/actor.dart';
import 'package:frontend/model/director.dart';

part '../generated/response/content_response_dto.g.dart';

@JsonSerializable()
class ContentResponseDto {
  ContentResponseDto({
    required this.id,
    required this.title,
    required this.description,
    required this.contentType,
    required this.genres,
    required this.actors,
    required this.directors,
    this.base64Image,
    this.trailerUrl,
    required this.productionCompanyId,
    required this.productionCompanyName,
  });

  final int id;
  final String title;
  final String description;
  final String contentType;
  final List<String> genres;
  final List<Actor> actors;
  final List<Director> directors;
  final String? base64Image;
  final String? trailerUrl;
  final int productionCompanyId;
  final String productionCompanyName;

  factory ContentResponseDto.fromJson(Map<String, dynamic> json) => _$ContentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentResponseDtoToJson(this);
}
