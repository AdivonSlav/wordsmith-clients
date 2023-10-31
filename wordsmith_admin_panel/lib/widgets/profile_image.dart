import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:wordsmith_utils/image_helper.dart";
import "package:wordsmith_utils/size_config.dart";

class ProfileImageWidget extends StatefulWidget {
  final String placeholderImage =
      "assets/images/profile_image_placeholder.jpeg";
  final String? profileImagePath;
  final double? width;
  final double? height;
  final double? scale;
  final Future<void> Function(XFile file) callbackFunction;

  const ProfileImageWidget({
    super.key,
    this.profileImagePath,
    this.width,
    this.height,
    this.scale,
    required this.callbackFunction,
  });

  @override
  State<StatefulWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  late String _apiUrl;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    _apiUrl = const String.fromEnvironment("API_URL");

    return GestureDetector(
      onTap: () async {
        var file = await ImageHelper.pickImage();

        if (file != null) {
          widget.callbackFunction(file);
        }
      },
      child: MouseRegion(
        onEnter: (details) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (details) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_isHovered ? 0.5 : 1.0),
                  BlendMode.dstATop,
                ),
                child: widget.profileImagePath == null
                    ? Image.asset(
                        widget.placeholderImage,
                        scale: widget.scale ?? 1.0,
                        width: widget.width ??
                            SizeConfig.safeBlockHorizontal * 25.0,
                        height: widget.height ??
                            SizeConfig.safeBlockVertical * 25.0,
                      )
                    : Image.network(
                        "$_apiUrl${widget.profileImagePath}",
                        width: widget.width ??
                            SizeConfig.safeBlockHorizontal * 25.0,
                        height: widget.height ??
                            SizeConfig.safeBlockVertical * 25.0,
                      )),
            Positioned(
              child: Visibility(
                visible: _isHovered,
                child: Icon(
                  Icons.edit,
                  size: SizeConfig.safeBlockHorizontal * 5.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
