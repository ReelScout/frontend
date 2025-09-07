import 'package:dio/dio.dart';
import 'package:frontend/dto/response/custom_response_dto.dart';

// Generic fallback shown when backend message is unavailable
const String kGenericErrorMessage =
    'An unexpected error occurred. Please contact the administrator.';

String mapDioError(
  DioException e, {
  String fallback = kGenericErrorMessage,
}) {
  // Prefer meaningful messages from the backend response body
  try {
    final data = e.response?.data;
    // Common API shapes: { message }, { error }, { detail }, validation { errors }
    if (data is Map<String, dynamic>) {
      // Try our known DTO shape first
      try {
        final custom = CustomResponseDto.fromJson(data);
        if (custom.message.isNotEmpty) return custom.message;
      } catch (_) {
        // ignore and try other common keys
      }

      // Fallback keys in order of likelihood
      final keysInOrder = ['message', 'error', 'detail', 'title'];
      for (final k in keysInOrder) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) {
          return v.trim();
        }
      }

      // Handle validation style: { errors: { field: ["msg1", "msg2"] } }
      final errors = data['errors'];
      if (errors is Map) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.trim().isNotEmpty) {
              return first.trim();
            }
          } else if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    }

    // Some backends return plain text bodies for errors
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
  } catch (_) {
    // ignore parsing errors and fall back
  }

  // Then fallback to Dio's statusMessage/error/message or provided fallback
  return e.response?.statusMessage?.trim().isNotEmpty == true
      ? e.response!.statusMessage!
      : (e.error?.toString() ?? e.message ?? fallback);
}
