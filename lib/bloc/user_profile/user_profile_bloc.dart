import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required UserService userService,
  })  : _userService = userService,
        super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
  }

  final UserService _userService;

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    try {
      final user = await _userService.getCurrentUser();
      emit(UserProfileLoaded(user: user));
    } on DioException catch (e) {
      // Use interceptor's standardized error messages
      final errorMessage = e.error?.toString() ?? 'Failed to load profile';
      emit(UserProfileError(message: errorMessage));
    } catch (e) {
      emit(UserProfileError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> _onClearUserProfile(
    ClearUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileInitial());
  }
}