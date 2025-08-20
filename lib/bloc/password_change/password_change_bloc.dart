import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../services/user_service.dart';
import '../../dto/request/user_password_change_request_dto.dart';
import '../../dto/response/custom_response_dto.dart';
import 'password_change_event.dart';
import 'password_change_state.dart';

class PasswordChangeBloc extends Bloc<PasswordChangeEvent, PasswordChangeState> {
  PasswordChangeBloc({required UserService userService})
      : _userService = userService,
        super(PasswordChangeInitial()) {
    on<PasswordChangeSubmitted>(_onSubmitted);
    on<PasswordChangeReset>(_onReset);
  }

  final UserService _userService;

  Future<void> _onSubmitted(
    PasswordChangeSubmitted event,
    Emitter<PasswordChangeState> emit,
  ) async {
    emit(PasswordChangeLoading());

    try {
      final request = UserPasswordChangeRequestDto(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      final response = await _userService.changePassword(request);
      emit(PasswordChangeSuccess(message: response.message));
    } on DioException catch (e) {
      String errorMessage = e.error?.toString() ?? 'Failed to change password';

      if (e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          errorMessage = customResponse.message;
        } catch (_) {
          errorMessage = e.error?.toString() ?? 'Failed to change password';
        }
      }

      emit(PasswordChangeFailure(error: errorMessage));
    } catch (e) {
      emit(PasswordChangeFailure(error: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> _onReset(
    PasswordChangeReset event,
    Emitter<PasswordChangeState> emit,
  ) async {
    emit(PasswordChangeInitial());
  }
}
