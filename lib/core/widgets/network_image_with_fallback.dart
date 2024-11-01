import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final String fallbackAssetPath;

  const NetworkImageWithFallback({
    Key? key,
    required this.imageUrl,
    required this.fallbackAssetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover, // Ensures the image covers the available space
      placeholder: (context, url) => Image.asset(
        fallbackAssetPath,
        fit: BoxFit.cover, // Covers available space for the placeholder too
      ),
      errorWidget: (context, url, error) => Image.asset(
        fallbackAssetPath,
        fit: BoxFit.cover,
      ),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }
}
