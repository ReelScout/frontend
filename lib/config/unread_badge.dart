import 'package:flutter/foundation.dart';

class UnreadBadge {
  final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(false);

  void markUnread() {
    if (!hasUnread.value) hasUnread.value = true;
  }

  void setUnread(bool v) {
    hasUnread.value = v;
  }

  void clear() {
    if (hasUnread.value) hasUnread.value = false;
  }
}

final UnreadBadge unreadBadge = UnreadBadge();

