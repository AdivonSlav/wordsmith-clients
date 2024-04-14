import 'dart:convert';
import 'dart:typed_data';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/size_config.dart';

class EbookImageWidget extends StatefulWidget {
  final String? encodedCoverArt;
  final String? coverArtUrl;
  final double? width;
  final double? height;
  final double? scale;
  final BoxFit? fit;
  final Alignment? imageAlignment;
  final bool addShadow;

  const EbookImageWidget({
    super.key,
    this.encodedCoverArt,
    this.coverArtUrl,
    this.width,
    this.height,
    this.scale,
    this.fit,
    this.imageAlignment,
    this.addShadow = true,
  });

  @override
  State<StatefulWidget> createState() => _EbookImageWidgetState();
}

class _EbookImageWidgetState extends State<EbookImageWidget> {
  final _logger = LogManager.getLogger("EBookImageWidget");
  final String _apiUrl = BaseProvider.apiUrl;

  final _defaultWidth = double.maxFinite;
  final _defaultHeight = SizeConfig.safeBlockVertical * 40.0;
  final _darkThemeShadowColor = const Color(0xFFF5F5F5);
  final _whiteThemeShadowColor = const Color(0XFF333333);

  Uint8List _toByteArray(String encodedImage) {
    return base64Decode(encodedImage);
  }

  BoxShadow _buildBoxShadow() {
    var adaptiveTheme = AdaptiveTheme.of(context);

    if (adaptiveTheme.mode == AdaptiveThemeMode.dark) {
      return BoxShadow(
        color: _darkThemeShadowColor.withOpacity(0.2),
        spreadRadius: 2.0,
        blurRadius: 4.0,
        offset: const Offset(0.0, 3.0),
      );
    }

    return BoxShadow(
      color: _whiteThemeShadowColor.withOpacity(0.6),
      spreadRadius: 4.0,
      blurRadius: 8.0,
      offset: const Offset(0.0, 3.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? coverArtBytes;

    try {
      if (widget.encodedCoverArt != null) {
        coverArtBytes = _toByteArray(widget.encodedCoverArt!);
      }
    } catch (error, stackTrace) {
      _logger.severe("Could not decode ebook cover art!", error, stackTrace);
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
              boxShadow: widget.addShadow
                  ? [
                      _buildBoxShadow(),
                    ]
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
