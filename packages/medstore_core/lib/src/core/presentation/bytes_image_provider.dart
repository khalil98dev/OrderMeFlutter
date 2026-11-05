import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// An image whose bytes come from our own code (an authenticated API call) instead of a public URL.
///
/// Flutter's image cache keys it by [cacheKey]: two widgets showing the same cover share one decoded
/// image, and scrolling back to a row does not download it again. Change the key (or [evict]) when the
/// image changes on the server.
@immutable
class BytesImageProvider extends ImageProvider<BytesImageProvider> {
  const BytesImageProvider({required this.cacheKey, required this.load});

  final String cacheKey;

  /// Returns the encoded image (JPEG/PNG/WebP), or null when there is none or it failed.
  final Future<Uint8List?> Function() load;

  @override
  Future<BytesImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<BytesImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(BytesImageProvider key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(_decode(decode));

  Future<ImageInfo> _decode(ImageDecoderCallback decode) async {
    final bytes = await load();
    if (bytes == null || bytes.isEmpty) {
      // Reported to the Image widget's errorBuilder, which shows the placeholder instead.
      throw StateError('No image for $cacheKey');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image);
  }

  @override
  bool operator ==(Object other) => other is BytesImageProvider && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;

  @override
  String toString() => 'BytesImageProvider($cacheKey)';
}
