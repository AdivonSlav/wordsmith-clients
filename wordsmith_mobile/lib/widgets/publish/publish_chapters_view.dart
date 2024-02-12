import 'package:flutter/material.dart';

class PublishChaptersView extends StatelessWidget {
  final List<String> chapters;

  const PublishChaptersView({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Chapters"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: chapters.map((chapterName) {
                    return ListTile(
                      title: Text(chapterName),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("View chapters"),
    );
  }
}
