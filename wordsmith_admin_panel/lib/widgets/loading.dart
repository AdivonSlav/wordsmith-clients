import "package:flutter/material.dart";
import "package:wordsmith_utils/size_config.dart";

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? strokeWidth;

  const LoadingWidget({super.key, this.width, this.height, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? SizeConfig.safeBlockHorizontal * 15.0,
      height: height ?? SizeConfig.safeBlockVertical * 15.0,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? SizeConfig.safeBlockHorizontal * 0.75,
      ),
    );
  }
}
