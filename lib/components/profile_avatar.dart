import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
      try {
        // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
        String cleanBase64 = base64Image!;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        
        final Uint8List imageBytes = base64Decode(cleanBase64);
        
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to default icon if image fails to load
            return _buildFallbackAvatar(context);
          },
        );
      } catch (e) {
        // Fallback to default icon if base64 decoding fails
        return _buildFallbackAvatar(context);
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