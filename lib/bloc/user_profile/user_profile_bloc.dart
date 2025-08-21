import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import '../../services/token_service.dart';
import '../../dto/response/custom_response_dto.dart';
import '../../dto/response/user_response_dto.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required UserService userService,
    required TokenService tokenService,
  })  : _userService = userService,
        _tokenService = tokenService,
        super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<ClearUserProfile>(_onClearUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  final UserService _userService;
  final TokenService _tokenService;

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    try {
      final user = await _userService.getCurrentUser();
      emit(UserProfileLoaded(user: user));
    } on DioException catch (e) {
      String errorMessage = e.error?.toString() ?? 'Failed to load profile';
      
      if (e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          errorMessage = customResponse.message;
        } catch (_) {
          errorMessage = e.error?.toString() ?? 'Failed to load profile';
        }
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

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    // Get current user to check for username changes
    // Allow updates from both UserProfileLoaded and UserProfileError states
    if (state is! UserProfileLoaded && state is! UserProfileError) return;
    
    // Get current user data - need to handle both loaded and error states
    UserResponseDto? currentUser;
    if (state is UserProfileLoaded) {
      currentUser = (state as UserProfileLoaded).user;
    } else {
      // If in error state, we need to reload user data first
      try {
        currentUser = await _userService.getCurrentUser();
      } catch (e) {
        emit(UserProfileError(message: 'Failed to get current user data'));
        return;
      }
    }
    
    emit(UserProfileUpdating());

    try {
      // Check if username is being changed
      final isUsernameChanged = currentUser.username != event.userRequest.username;

      // Call update endpoint
      final response = await _userService.update(event.userRequest);

      // If username changed and backend returned new token, update stored token
      if (isUsernameChanged && response != null && response.accessToken.isNotEmpty) {
        await _tokenService.saveToken(response.accessToken);
      }

      emit(UserProfileUpdateSuccess(message: 'Profile updated'));
      
      // Reload the profile to get updated data
      add(LoadUserProfile());
    } on DioException catch (e) {
      String errorMessage = e.error?.toString() ?? 'Failed to update profile';
      
      if (e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          errorMessage = customResponse.message;
        } catch (_) {
          errorMessage = e.error?.toString() ?? 'Failed to update profile';
        }
      }
      
      emit(UserProfileError(message: errorMessage));
    } catch (e) {
      emit(UserProfileError(message: 'An unexpected error occurred: $e'));
    }
  }
}