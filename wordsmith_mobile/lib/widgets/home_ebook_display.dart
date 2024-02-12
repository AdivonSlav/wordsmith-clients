import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';

class HomeEBookDisplayWidget extends StatelessWidget {
  final String title;
  final List<EBook> ebooks;

  const HomeEBookDisplayWidget(
      {super.key, required this.title, required this.ebooks});

  @override
  Widget build(BuildContext context) {
    final _logger = LogManager.getLogger("HomeEBookDisplay");
    var theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32.0,
            ),
          ),
        ),
        CarouselSlider.builder(
          options: CarouselOptions(
            aspectRatio: 1.5,
            viewportFraction: 0.50,
            pageSnapping: true,
            enlargeCenterPage: true,
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
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EBookScreenWidget(ebook: ebooks[itemIndex]),
                  ),
                ),
                child: EBookImageWidget(
                  coverArtUrl: ebooks[itemIndex].coverArt.imagePath,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
