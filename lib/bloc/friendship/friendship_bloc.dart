import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/friendship/friendship_event.dart';
import 'package:frontend/bloc/friendship/friendship_state.dart';
import 'package:frontend/services/friendship_service.dart';
import 'package:frontend/utils/error_utils.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  FriendshipBloc({required FriendshipService friendshipService})
      : _friendshipService = friendshipService,
        super(const FriendshipInitial()) {
    on<LoadFriendshipData>(_onLoad);
    on<RefreshFriendshipData>(_onLoad);
    on<SendFriendRequest>(_onSendRequest);
    on<AcceptFriendRequest>(_onAccept);
    on<RejectFriendRequest>(_onReject);
    on<RemoveFriend>(_onRemove);
  }

  final FriendshipService _friendshipService;

  Future<void> _onLoad(
    FriendshipEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final friends = await _friendshipService.getFriends();
      final incoming = await _friendshipService.getIncomingRequests();
      final outgoing = await _friendshipService.getOutgoingRequests();
      emit(FriendshipLoaded(friends: friends, incoming: incoming, outgoing: outgoing));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(FriendshipError(msg));
    }
  }

  Future<void> _onSendRequest(
    SendFriendRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    final previous = state;
    try {
      final res = await _friendshipService.sendFriendRequest(event.memberId);
      // reload lists to reflect outgoing request
      final friends = await _friendshipService.getFriends();
      final incoming = await _friendshipService.getIncomingRequests();
      final outgoing = await _friendshipService.getOutgoingRequests();
      emit(FriendshipLoaded(
        friends: friends,
        incoming: incoming,
        outgoing: outgoing,
        lastMessage: res.message,
      ));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (previous is FriendshipLoaded) {
        emit(previous.copyWith(lastMessage: msg));
      } else {
        emit(FriendshipError(msg));
      }
    }
  }

  Future<void> _onAccept(
    AcceptFriendRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    final previous = state;
    try {
      final res = await _friendshipService.acceptFriendRequest(event.memberId);
      final friends = await _friendshipService.getFriends();
      final incoming = await _friendshipService.getIncomingRequests();
      final outgoing = await _friendshipService.getOutgoingRequests();
      emit(FriendshipLoaded(
        friends: friends,
        incoming: incoming,
        outgoing: outgoing,
        lastMessage: res.message,
      ));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (previous is FriendshipLoaded) {
        emit(previous.copyWith(lastMessage: msg));
      } else {
        emit(FriendshipError(msg));
      }
    }
  }

  Future<void> _onReject(
    RejectFriendRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    final previous = state;
    try {
      final res = await _friendshipService.rejectFriendRequest(event.memberId);
      final friends = await _friendshipService.getFriends();
      final incoming = await _friendshipService.getIncomingRequests();
      final outgoing = await _friendshipService.getOutgoingRequests();
      emit(FriendshipLoaded(
        friends: friends,
        incoming: incoming,
        outgoing: outgoing,
        lastMessage: res.message,
      ));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (previous is FriendshipLoaded) {
        emit(previous.copyWith(lastMessage: msg));
      } else {
        emit(FriendshipError(msg));
      }
    }
  }

  Future<void> _onRemove(
    RemoveFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    final previous = state;
    try {
      final res = await _friendshipService.removeFriend(event.memberId);
      final friends = await _friendshipService.getFriends();
      final incoming = await _friendshipService.getIncomingRequests();
      final outgoing = await _friendshipService.getOutgoingRequests();
      emit(FriendshipLoaded(
        friends: friends,
        incoming: incoming,
        outgoing: outgoing,
        lastMessage: res.message,
      ));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (previous is FriendshipLoaded) {
        emit(previous.copyWith(lastMessage: msg));
      } else {
        emit(FriendshipError(msg));
      }
    }
  }
}

