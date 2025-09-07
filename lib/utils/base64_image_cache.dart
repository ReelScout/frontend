import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

// Simple in-memory cache for decoded base64 images to avoid repeat decoding cost.
// Cache by sanitized base64 string (without data URL prefix).
class _Base64ImageCache {
  static const int _maxEntries = 256;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  Uint8List? get(String key) => _cache[key];

  void set(String key, Uint8List bytes) {
    _cache[key] = bytes;
    // Evict LRU when exceeding max size
    if (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

final _cache = _Base64ImageCache();

String _sanitize(String input) {
  final idx = input.indexOf(',');
  return idx != -1 ? input.substring(idx + 1) : input;
}

Uint8List? decodeBase64Cached(String? base64) {
  if (base64 == null || base64.isEmpty) return null;
  final clean = _sanitize(base64);
  final cached = _cache.get(clean);
  if (cached != null) return cached;
  try {
    final bytes = base64Decode(clean);
    _cache.set(clean, bytes);
    return bytes;
  } catch (_) {
    return null;
  }
}

