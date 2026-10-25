import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.error,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fadeOutDuration = const Duration(milliseconds: 200),
    this.memCacheWidth,
    this.memCacheHeight,
    this.backgroundColor,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? error;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Color? backgroundColor;

  bool _isSvg(String url) => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final safeUrl = (url != null && url!.trim().isNotEmpty)
        ? url!.trim()
        : null;

    Widget content;

    if (safeUrl == null) {
      content = error ?? _DefaultError(width: width, height: height);
    } else if (_isSvg(safeUrl)) {
      content = SvgPicture.network(
        safeUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => placeholder ?? _DefaultPlaceholder(),
      );
    } else {
      content = CachedNetworkImage(
        imageUrl: safeUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (ctx, _) => placeholder ?? _DefaultPlaceholder(),
        errorWidget: (ctx, _, __) =>
            error ?? _DefaultError(width: width, height: height),
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    if (backgroundColor != null) {
      content = ColoredBox(color: backgroundColor!, child: content);
    }

    return content;
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: AppColors.primary500),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withOpacity(0.15),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }
}
