import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

class EBookImageWidget extends StatefulWidget {
  final String? encodedCoverArt;
  final String? coverArtUrl;
  final double? width;
  final double? scale;

  const EBookImageWidget({
    super.key,
    this.encodedCoverArt,
    this.coverArtUrl,
    this.width,
    this.scale,
  });

  @override
  State<StatefulWidget> createState() => _EBookImageWidgetState();
}

class _EBookImageWidgetState extends State<EBookImageWidget> {
  final _logger = LogManager.getLogger("EBookImageWidget");
  final String _apiUrl = const String.fromEnvironment("API_URL");

  final _defaultWidth = SizeConfig.safeBlockHorizontal * 60.0;

  Uint8List _toByteArray(String encodedImage) {
    return base64Decode(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: null,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: widget.width ?? _defaultWidth,
            height: widget.width == null
                ? _defaultWidth * 1.5
                : widget.width! * 1.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
