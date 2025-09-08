import 'package:frontend/services/user_service.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:flutter/foundation.dart';

class UserLookup {
  UserLookup(
    this._userService, {
    Duration ttl = const Duration(minutes: 10),
    int maxEntries = 200,
  })  : _ttl = ttl,
        _maxEntries = maxEntries;

  final UserService _userService;
  final Map<int, _CacheEntry> _cache = {};
  final Duration _ttl;
  final int _maxEntries;

  Future<UserResponseDto?> getById(int id) async {
    final cached = _cache[id];
    if (cached != null && !_isExpired(cached)) {
      return cached.user;
    }
    try {
      final dto = await _userService.getById(id);
      _insert(id, dto);
      return dto;
    } catch (_) {
      return null;
    }
  }

  Future<Map<int, UserResponseDto>> getManyById(Iterable<int> ids) async {
    final result = <int, UserResponseDto>{};
    final toFetch = <int>[];
    for (final id in ids) {
      final cached = _cache[id];
      if (cached != null && !_isExpired(cached)) {
        result[id] = cached.user;
      } else {
        toFetch.add(id);
      }
    }
    if (toFetch.isNotEmpty) {
      await Future.wait(
        toFetch.map((id) async {
          final u = await getById(id);
          if (u != null) result[id] = u;
        }),
      );
    }
    return result;
  }

  bool _isExpired(_CacheEntry entry) =>
      DateTime.now().difference(entry.insertedAt) > _ttl;

  void _insert(int id, UserResponseDto user) {
    _cache[id] = _CacheEntry(user: user, insertedAt: DateTime.now());
    if (_cache.length > _maxEntries) {
      // Evict the oldest
      int? oldestKey;
      DateTime? oldestTime;
      _cache.forEach((key, value) {
        if (oldestTime == null || value.insertedAt.isBefore(oldestTime!)) {
          oldestTime = value.insertedAt;
          oldestKey = key;
        }
      });
      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
  }
}

@immutable
class _CacheEntry {
  const _CacheEntry({required this.user, required this.insertedAt});
  final UserResponseDto user;
  final DateTime insertedAt;
}
