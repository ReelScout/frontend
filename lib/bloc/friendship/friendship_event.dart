import 'package:equatable/equatable.dart';

abstract class FriendshipEvent extends Equatable {
  const FriendshipEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendshipData extends FriendshipEvent {
  const LoadFriendshipData();
}

class RefreshFriendshipData extends FriendshipEvent {
  const RefreshFriendshipData();
}

class SendFriendRequest extends FriendshipEvent {
  const SendFriendRequest({required this.memberId});
  final int memberId;

  @override
  List<Object?> get props => [memberId];
}

class AcceptFriendRequest extends FriendshipEvent {
  const AcceptFriendRequest({required this.memberId});
  final int memberId;

  @override
  List<Object?> get props => [memberId];
}

class RejectFriendRequest extends FriendshipEvent {
  const RejectFriendRequest({required this.memberId});
  final int memberId;

  @override
  List<Object?> get props => [memberId];
}

class RemoveFriend extends FriendshipEvent {
  const RemoveFriend({required this.memberId});
  final int memberId;

  @override
  List<Object?> get props => [memberId];
}

