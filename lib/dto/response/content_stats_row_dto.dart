import 'package:json_annotation/json_annotation.dart';

part '../generated/response/content_stats_row_dto.g.dart';

@JsonSerializable()
class ContentStatsRowDto {
  const ContentStatsRowDto({
    required this.contentId,
    required this.title,
    required this.threads,
    required this.posts,
    required this.reports,
    required this.saves,
  });

  factory ContentStatsRowDto.fromJson(Map<String, dynamic> json) =>
      _$ContentStatsRowDtoFromJson(json);

  final int contentId;
  final String title;
  final int threads;
  final int posts;
  final int reports;
  final int saves;

  Map<String, dynamic> toJson() => _$ContentStatsRowDtoToJson(this);
}

