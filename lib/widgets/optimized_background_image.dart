import 'package:flutter/material.dart';

/// Фон с уменьшенным декодированием — меньше RAM на эмуляторе и слабых устройствах.
class OptimizedBackgroundImage extends StatelessWidget {
  const OptimizedBackgroundImage({
    super.key,
    required this.assetPath,
  });

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (size.width * dpr * 0.75).round().clamp(1, 720);
    final cacheH = (size.height * dpr * 0.75).round().clamp(1, 1280);

    return Image(
      image: ResizeImage(
        AssetImage(assetPath),
        width: cacheW,
        height: cacheH,
      ),
      key: ValueKey(assetPath),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF121212)
              : const Color(0xFFF5F5F5),
        );
      },
    );
  }

  static ImageProvider resizedProvider(BuildContext context, String assetPath) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (size.width * dpr * 0.75).round().clamp(1, 720);
    final cacheH = (size.height * dpr * 0.75).round().clamp(1, 1280);
    return ResizeImage(AssetImage(assetPath), width: cacheW, height: cacheH);
  }
}
