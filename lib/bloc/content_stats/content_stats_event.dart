import 'package:equatable/equatable.dart';

abstract class ContentStatsEvent extends Equatable {
  const ContentStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyContentsStatsRequested extends ContentStatsEvent {
  const LoadMyContentsStatsRequested();
}

