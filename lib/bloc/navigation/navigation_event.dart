import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class TabSelected extends NavigationEvent {
  const TabSelected({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}