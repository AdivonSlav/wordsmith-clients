import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';

class HomeEbookDisplayWidget extends StatelessWidget {
  final String title;
  final List<Ebook> ebooks;

  const HomeEbookDisplayWidget(
      {super.key, required this.title, required this.ebooks});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),
          ),
        ),
        CarouselSlider.builder(
          options: CarouselOptions(
            viewportFraction: 0.50,
            pageSnapping: true,
            enlargeCenterPage: false,
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
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        EbookScreenWidget(ebookId: ebooks[itemIndex].id),
                  ));
                },
                child: EbookImageWidget(
                  coverArtUrl: ebooks[itemIndex].coverArt.imagePath,
                  fit: BoxFit.fill,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
