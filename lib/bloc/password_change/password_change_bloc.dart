import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/dto/request/user_password_change_request_dto.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/error_utils.dart';
import 'package:frontend/bloc/password_change/password_change_event.dart';
import 'package:frontend/bloc/password_change/password_change_state.dart';

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
      emit(PasswordChangeFailure(error: mapDioError(e)));
    } catch (_) {
      emit(const PasswordChangeFailure(error: kGenericErrorMessage));
    }
  }

  Future<void> _onReset(
    PasswordChangeReset event,
    Emitter<PasswordChangeState> emit,
  ) async {
    emit(PasswordChangeInitial());
  }
}
