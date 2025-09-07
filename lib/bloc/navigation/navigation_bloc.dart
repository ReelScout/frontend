import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/navigation/navigation_event.dart';
import 'package:frontend/bloc/navigation/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(selectedIndex: 0)) {
    on<TabSelected>(_onTabSelected);
  }

  void _onTabSelected(TabSelected event, Emitter<NavigationState> emit) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}