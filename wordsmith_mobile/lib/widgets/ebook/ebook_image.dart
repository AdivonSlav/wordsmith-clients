import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

class EBookImageWidget extends StatefulWidget {
  final String? encodedCoverArt;
  final String? coverArtUrl;
  final double? width;
  final double? height;
  final double? scale;
  final BoxFit? fit;
  final Alignment? imageAlignment;

  const EBookImageWidget({
    super.key,
    this.encodedCoverArt,
    this.coverArtUrl,
    this.width,
    this.height,
    this.scale,
    this.fit,
    this.imageAlignment,
  });

  @override
  State<StatefulWidget> createState() => _EBookImageWidgetState();
}

class _EBookImageWidgetState extends State<EBookImageWidget> {
  final _logger = LogManager.getLogger("EBookImageWidget");
  final String _apiUrl = const String.fromEnvironment("API_URL");

  final _defaultWidth = double.maxFinite;
  final _defaultHeight = SizeConfig.safeBlockVertical * 40.0;

  Uint8List _toByteArray(String encodedImage) {
    return base64Decode(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
    var adaptiveTheme = AdaptiveTheme.of(context);
    Uint8List? coverArtBytes;

    try {
      if (widget.encodedCoverArt != null) {
        coverArtBytes = _toByteArray(widget.encodedCoverArt!);
      }
    } catch (error) {
      _logger.severe("Could not decode ebook cover art $error");
    }

    late ImageProvider<Object> imageProvider;

    if (coverArtBytes != null || widget.coverArtUrl != null) {
      imageProvider = (coverArtBytes != null
              ? MemoryImage(coverArtBytes)
              : NetworkImage("$_apiUrl${widget.coverArtUrl}"))
          as ImageProvider<Object>;
    } else {
      imageProvider =
          const AssetImage("assets/images/no_image_placeholder.png");
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: widget.imageAlignment ?? Alignment.center,
          child: Container(
            width: widget.width ?? _defaultWidth,
            height: widget.height ?? _defaultHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: widget.fit ?? BoxFit.contain,
              ),
              boxShadow: [
                BoxShadow(
                  color: adaptiveTheme.mode == AdaptiveThemeMode.dark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.6),
                  spreadRadius: 4.0,
                  blurRadius: 8.0,
                  offset: const Offset(0.0, 3.0),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
