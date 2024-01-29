import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/ebook_image.dart';
import 'package:wordsmith_utils/models/ebook.dart';

class HomeEBookDisplayWidget extends StatelessWidget {
  final String title;
  final List<EBook> ebooks;

  const HomeEBookDisplayWidget(
      {super.key, required this.title, required this.ebooks});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 1.5,
                viewportFraction: 0.55,
                pageSnapping: false,
              ),
              itemCount: ebooks.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                if (ebooks.isEmpty) {
                  return Container();
                }

                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: EBookImageWidget(
                    coverArtUrl: ebooks[itemIndex].coverArt.imagePath,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}