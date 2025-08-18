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
      String errorMessage = 'Failed to load profile';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication required';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'Access denied';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }
      
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