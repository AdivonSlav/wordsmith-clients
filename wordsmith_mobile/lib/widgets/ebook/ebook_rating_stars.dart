import 'package:flutter/material.dart';

class EBookRatingStarsWidget extends StatelessWidget {
  final double? rating;

  const EBookRatingStarsWidget({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    const starColor = Color(0xFFFF9529);

    return const Row(
      children: <Widget>[
        Icon(
          Icons.star_outline_outlined,
          size: 20.0,
          color: starColor,
        ),
        Icon(
          Icons.star_outline_outlined,
          size: 20.0,
          color: starColor,
        ),
        Icon(
          Icons.star_outline_outlined,
          size: 20.0,
          color: starColor,
        ),
        Icon(
          Icons.star_outline_outlined,
          size: 20.0,
          color: starColor,
        ),
        Icon(
          Icons.star_outline_outlined,
          size: 20.0,
          color: starColor,
        ),
      ],
    );
  }
}
