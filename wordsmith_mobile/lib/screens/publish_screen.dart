import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/publish_edit.dart';
import 'package:wordsmith_mobile/widgets/publish_upload.dart';
import 'package:wordsmith_utils/models/ebook_parse.dart';

class PublishScreenWidget extends StatefulWidget {
  const PublishScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => PublishScreenWidgetState();
}

class PublishScreenWidgetState extends State<PublishScreenWidget> {
  late EBookParse parsedEbook;
  bool hasParsed = false;

  void getParsedEBook(EBookParse ebook) async {
    setState(() {
      parsedEbook = ebook;
      hasParsed = !hasParsed;
    });
  }

  void submitEditedEBook(EBookParse ebook) async {}

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Publish story",
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: !hasParsed
          ? PublishUploadWidget(
              onUploadCallback: getParsedEBook,
            )
          : PublishEditWidget(
              parsedEbook: parsedEbook,
              onEditCallback: submitEditedEBook,
            ),
    );
  }
}
