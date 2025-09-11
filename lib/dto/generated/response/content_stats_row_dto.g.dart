// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/content_stats_row_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentStatsRowDto _$ContentStatsRowDtoFromJson(Map<String, dynamic> json) =>
    ContentStatsRowDto(
      contentId: (json['contentId'] as num).toInt(),
      title: json['title'] as String,
      threads: (json['threads'] as num).toInt(),
      posts: (json['posts'] as num).toInt(),
      reports: (json['reports'] as num).toInt(),
      saves: (json['saves'] as num).toInt(),
    );

Map<String, dynamic> _$ContentStatsRowDtoToJson(ContentStatsRowDto instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'title': instance.title,
      'threads': instance.threads,
      'posts': instance.posts,
      'reports': instance.reports,
      'saves': instance.saves,
    };
