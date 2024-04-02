import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EbookRatingMinimalDisplayWidget extends StatelessWidget {
  final double? rating;
  final double starSize;

  const EbookRatingMinimalDisplayWidget({
    super.key,
    required this.rating,
    this.starSize = 20.0,
  });

  Widget _buildRatingBar() {
    const Color starColor = Color(0xFFFF9529);

    return RatingBar.builder(
      ignoreGestures: true,
      initialRating: rating ?? 0.0,
      allowHalfRating: true,
      itemSize: starSize,
      maxRating: 5.0,
      itemBuilder: (context, _) => const Icon(Icons.star, color: starColor),
      onRatingUpdate: (rating) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildRatingBar(),
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
