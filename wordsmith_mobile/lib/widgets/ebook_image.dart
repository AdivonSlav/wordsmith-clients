import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

class EBookImageWidget extends StatefulWidget {
  final String encodedCoverArt;
  final double? width;
  final double? scale;

  const EBookImageWidget({
    super.key,
    required this.encodedCoverArt,
    this.width,
    this.scale,
  });

  @override
  State<StatefulWidget> createState() => _EBookImageWidgetState();
}

class _EBookImageWidgetState extends State<EBookImageWidget> {
  final _logger = LogManager.getLogger("EBookImageWidget");

  final _defaultWidth = SizeConfig.safeBlockHorizontal * 60.0;

  Uint8List _toByteArray(String encodedImage) {
    return base64Decode(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
    late Uint8List coverArtBytes;

    try {
      coverArtBytes = _toByteArray(widget.encodedCoverArt);
    } catch (error) {
      _logger.severe("Could not decode ebook cover art $error");
    }

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
                image: MemoryImage(coverArtBytes),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
