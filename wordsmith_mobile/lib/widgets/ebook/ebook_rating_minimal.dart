import 'package:flutter/material.dart';

class EbookRatingMinimalWidget extends StatelessWidget {
  final double? rating;
  final double starSize;
  final bool showAverage;

  const EbookRatingMinimalWidget({
    super.key,
    required this.rating,
    this.starSize = 20.0,
    this.showAverage = true,
  });

  Widget _buildStarIcons() {
    const Color starColor = Color(0xFFFF9529);

    List<Icon> icons = List.generate(5, (index) {
      if (rating != null) {
        var icon = Icons.star_outline;

        int filledStars = rating!.floor();
        double remainder = rating! - filledStars;

        if (index < filledStars) {
          icon = Icons.star;
        } else if (index == filledStars && remainder > 0.25) {
          icon = Icons.star_half;
        }

        return Icon(
          icon,
          size: starSize,
          color: starColor,
        );
      }

      return Icon(
        Icons.star_outline,
        size: starSize,
        color: starColor,
      );
    });

    return Row(
      children: icons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildStarIcons(),
          if (showAverage) const SizedBox(width: 10.0),
          if (showAverage)
            Text(
              rating?.toStringAsFixed(2) ?? "0",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
