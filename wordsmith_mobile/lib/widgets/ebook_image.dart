import 'dart:convert';
import 'dart:typed_data';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

class EBookImageWidget extends StatefulWidget {
  final String? encodedCoverArt;
  final String? coverArtUrl;
  final double? maxWidth;
  final double? scale;
  final BoxFit? fit;

  const EBookImageWidget({
    super.key,
    this.encodedCoverArt,
    this.coverArtUrl,
    this.maxWidth,
    this.scale,
    this.fit,
  });

  @override
  State<StatefulWidget> createState() => _EBookImageWidgetState();
}

class _EBookImageWidgetState extends State<EBookImageWidget> {
  final _logger = LogManager.getLogger("EBookImageWidget");
  final String _apiUrl = const String.fromEnvironment("API_URL");

  final _defaultMaxWidth = SizeConfig.safeBlockHorizontal * 70.0;

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

    var imageProvider = (coverArtBytes != null
            ? MemoryImage(coverArtBytes)
            : NetworkImage("$_apiUrl${widget.coverArtUrl}"))
        as ImageProvider<Object>;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: adaptiveTheme.mode == AdaptiveThemeMode.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.6),
              spreadRadius: 4.0,
              blurRadius: 8.0,
              offset: const Offset(0.0, 3.0),
            )
          ]),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? _defaultMaxWidth,
            ),
            child: Image(
              image: imageProvider,
              fit: widget.fit ?? BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
