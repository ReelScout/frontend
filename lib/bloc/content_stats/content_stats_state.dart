import 'package:equatable/equatable.dart';
import 'package:frontend/dto/response/content_stats_row_dto.dart';

abstract class ContentStatsState extends Equatable {
  const ContentStatsState();

  @override
  List<Object?> get props => [];
}

class ContentStatsInitial extends ContentStatsState {}

class ContentStatsLoading extends ContentStatsState {}

class ContentStatsLoaded extends ContentStatsState {
  const ContentStatsLoaded({required this.rows});

  final List<ContentStatsRowDto> rows;

  @override
  List<Object?> get props => [rows];
}

class ContentStatsError extends ContentStatsState {
  const ContentStatsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

