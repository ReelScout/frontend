import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/utils/base64_image_cache.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.base64Image,
    required this.size,
    this.fallbackColor,
    this.fallbackIconColor,
  });

  final String? base64Image;
  final double size;
  final Color? fallbackColor;
  final Color? fallbackIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: _buildAvatarContent(context),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (base64Image != null && base64Image!.isNotEmpty) {
      final Uint8List? imageBytes = decodeBase64Cached(base64Image);
      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(context),
        );
      }
    }
    
    // Fallback when no image is provided
    return _buildFallbackAvatar(context);
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fallbackColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: fallbackIconColor ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
