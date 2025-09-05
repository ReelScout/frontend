import 'package:json_annotation/json_annotation.dart';

part '../generated/request/watchlist_request_dto.g.dart';

@JsonSerializable()
class WatchlistRequestDto {
  const WatchlistRequestDto({
    required this.name,
    required this.isPublic,
  });

  final String name;
  final bool isPublic;

  factory WatchlistRequestDto.fromJson(Map<String, dynamic> json) => _$WatchlistRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistRequestDtoToJson(this);
}