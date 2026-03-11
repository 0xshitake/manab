import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Displays the perspective-warped card image as a thumbnail.
class CroppedCardDisplay extends StatelessWidget {
  const CroppedCardDisplay({
    super.key,
    required this.rgbaBytes,
    required this.width,
    required this.height,
  });

  /// Raw RGBA pixel bytes of the warped card.
  final Uint8List rgbaBytes;

  /// Image width in pixels.
  final int width;

  /// Image height in pixels.
  final int height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        // Display at ~1/4 size for thumbnail.
        width: width / 4.0,
        height: height / 4.0,
        child: _RgbaImage(
          rgbaBytes: rgbaBytes,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

/// Renders raw RGBA bytes as an image using [ui.decodeImageFromPixels].
class _RgbaImage extends StatefulWidget {
  const _RgbaImage({
    required this.rgbaBytes,
    required this.width,
    required this.height,
  });

  final Uint8List rgbaBytes;
  final int width;
  final int height;

  @override
  State<_RgbaImage> createState() => _RgbaImageState();
}

class _RgbaImageState extends State<_RgbaImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void didUpdateWidget(_RgbaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rgbaBytes, widget.rgbaBytes)) {
      _decodeImage();
    }
  }

  void _decodeImage() {
    ui.decodeImageFromPixels(
      widget.rgbaBytes,
      widget.width,
      widget.height,
      ui.PixelFormat.rgba8888,
      (image) {
        if (mounted) {
          setState(() => _image = image);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const SizedBox.shrink();
    }
    return RawImage(
      image: _image,
      fit: BoxFit.contain,
    );
  }
}
