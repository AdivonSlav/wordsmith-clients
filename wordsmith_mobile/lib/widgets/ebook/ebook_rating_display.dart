import 'package:flutter/material.dart';

class EbookRatingDisplayWidget extends StatelessWidget {
  final double? rating;
  final double? starSize;

  const EbookRatingDisplayWidget({
    super.key,
    required this.rating,
    this.starSize = 20.0,
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
        children: <Widget>[
          _buildStarIcons(),
          const SizedBox(width: 10.0),
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
