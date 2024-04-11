import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:wordsmith_utils/image_helper.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/size_config.dart";

class ProfileImageWidget extends StatefulWidget {
  final String? profileImagePath;
  final double? scale;
  final double? radius;
  final void Function(XFile file)? editCallback;

  const ProfileImageWidget({
    super.key,
    this.profileImagePath,
    this.scale,
    this.editCallback,
    this.radius,
  });

  @override
  State<StatefulWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  final String _placeholderImage =
      "assets/images/profile_image_placeholder.jpeg";
  final String _apiUrl = BaseProvider.apiUrl;

  final _defaultAvatarRadius = 64.0;

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholderImage = AssetImage(_placeholderImage);
    final profileImage = widget.profileImagePath != null
        ? NetworkImage("$_apiUrl${widget.profileImagePath!}")
        : null;

    return GestureDetector(
      onTap: widget.editCallback != null
          ? () async {
              var file = await ImageHelper.pickImage();

              if (file != null) {
                widget.editCallback!(file);
              }
            }
          : null,
      child: MouseRegion(
        onEnter: (details) {
          if (widget.editCallback == null) return;
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (details) {
          if (widget.editCallback == null) return;
          setState(() {
            _isHovered = false;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_isHovered ? 0.4 : 0.0),
                  BlendMode.srcATop,
                ),
                child: CircleAvatar(
                  foregroundImage: profileImage,
                  backgroundImage: defaultPlaceholderImage,
                  radius: widget.radius ?? _defaultAvatarRadius,
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
