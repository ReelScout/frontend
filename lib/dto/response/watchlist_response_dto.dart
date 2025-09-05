import 'package:json_annotation/json_annotation.dart';

part '../generated/response/watchlist_response_dto.g.dart';

@JsonSerializable()
class WatchlistResponseDto {
  const WatchlistResponseDto({
    required this.id,
    required this.name,
    required this.isPublic
  });

  final int id;
  final String name;
  final bool isPublic;

  factory WatchlistResponseDto.fromJson(Map<String, dynamic> json) => _$WatchlistResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistResponseDtoToJson(this);
}