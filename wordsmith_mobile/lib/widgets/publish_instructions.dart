import 'package:flutter/material.dart';
import 'package:wordsmith_utils/bullet_list.dart';

class PublishInstructionsWidget extends StatelessWidget {
  const PublishInstructionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Here you can post a story which will be visible to everyone",
        ),
        SizedBox(
          height: 14.0,
        ),
        Text(
          "Your uploaded EPUB file has been parsed and its metadata is shown below.",
        ),
        SizedBox(
          height: 14.0,
        ),
        Text(
          "Some considerations:",
        ),
        BulletList(strings: [
          "All edits besides the genre, maturity rating and price need to be done on the actual EPUB file. Perform those edits manually and reupload if necessary",
          "Titles should be clear and concise",
          "If the chapters shown are incorrect, then it means the EPUB is not properly configured. That should be fixed in your software of choice and reuploaded here",
        ])
      ],
    );
  }
}
