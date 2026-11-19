import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Widget gambar berita yang aman untuk Android, iOS, Desktop, dan Flutter Web (CORS-safe).
class NewsImage extends StatelessWidget {
  final String? url;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NewsImage({
    super.key,
    required this.url,
    this.height = 200,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    final placeholder = Container(
      height: height,
      width: effectiveWidth,
      color: AppColors.surfaceLight,
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    final errorWidget = Container(
      height: height,
      width: effectiveWidth,
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 6),
          Text(
            'Gambar Tidak Tersedia',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (url == null || url!.trim().isEmpty) {
      return _applyBorderRadius(errorWidget);
    }

    final imageUrl = url!.trim();

    Widget image;
    if (kIsWeb) {
      image = Image.network(
        imageUrl,
        height: height,
        width: effectiveWidth,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: effectiveWidth,
        fit: fit,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => errorWidget,
      );
    }

    return _applyBorderRadius(image);
  }

  Widget _applyBorderRadius(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
