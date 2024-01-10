import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_utils/image_helper.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

class ProfileImageWidget extends StatefulWidget {
  final String placeholderImage =
      "assets/images/profile_image_placeholder.jpeg";
  final String? profileImagePath;
  final double? scale;
  final double? radius;
  final Future<void> Function(XFile file)? editCallback;

  const ProfileImageWidget(
      {super.key,
      this.profileImagePath,
      this.scale,
      this.radius,
      this.editCallback});

  @override
  State<StatefulWidget> createState() => ProfileImageWidgetState();
}

class ProfileImageWidgetState extends State<ProfileImageWidget> {
  final _logger = LogManager.getLogger("ProfileImageWidget");
  final String _apiUrl = const String.fromEnvironment("API_URL");

  final editableImageOpacity = 0.4;
  final defaultImageOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholderImage = AssetImage(widget.placeholderImage);
    final profileImage = widget.profileImagePath != null
        ? NetworkImage("$_apiUrl${widget.profileImagePath!}")
        : null;

    return GestureDetector(
      onTap: widget.editCallback != null
          ? () async {
              _logger.info("Tapped on profile image for edit!");

              var file = await ImageHelper.pickImage();

              if (file != null) {
                // Cannnot be null as it is checked at onTap
                widget.editCallback!(file);
              }
            }
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircleAvatar(
            foregroundImage: profileImage,
            backgroundImage: defaultPlaceholderImage, // Fallback
            radius: widget.radius ?? SizeConfig.safeBlockHorizontal * 20.0,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(widget.editCallback == null
                  ? defaultImageOpacity
                  : editableImageOpacity),
            ),
            width: widget.radius != null
                ? widget.radius! * 2.0
                : SizeConfig.safeBlockHorizontal * 20.0 * 2.0,
            height: widget.radius != null
                ? widget.radius! * 2.0
                : SizeConfig.safeBlockHorizontal * 20.0 * 2.0,
          ),
          Positioned(
            child: Visibility(
              visible: widget.editCallback != null,
              child: Icon(
                Icons.edit,
                size: SizeConfig.safeBlockHorizontal * 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
