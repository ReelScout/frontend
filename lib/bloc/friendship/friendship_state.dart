import 'package:equatable/equatable.dart';
import 'package:frontend/dto/response/friendship_with_users_response_dto.dart';

abstract class FriendshipState extends Equatable {
  const FriendshipState();
  @override
  List<Object?> get props => [];
}

class FriendshipInitial extends FriendshipState {
  const FriendshipInitial();
}

class FriendshipLoading extends FriendshipState {
  const FriendshipLoading();
}

class FriendshipLoaded extends FriendshipState {
  const FriendshipLoaded({
    required this.friends,
    required this.incoming,
    required this.outgoing,
    this.lastMessage,
  });

  final List<FriendshipWithUsersResponseDto> friends;
  final List<FriendshipWithUsersResponseDto> incoming;
  final List<FriendshipWithUsersResponseDto> outgoing;
  final String? lastMessage;

  FriendshipLoaded copyWith({
    List<FriendshipWithUsersResponseDto>? friends,
    List<FriendshipWithUsersResponseDto>? incoming,
    List<FriendshipWithUsersResponseDto>? outgoing,
    String? lastMessage,
  }) => FriendshipLoaded(
    friends: friends ?? this.friends,
    incoming: incoming ?? this.incoming,
    outgoing: outgoing ?? this.outgoing,
    lastMessage: lastMessage,
  );

  @override
  List<Object?> get props => [friends, incoming, outgoing, lastMessage];
}

class FriendshipError extends FriendshipState {
  const FriendshipError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

