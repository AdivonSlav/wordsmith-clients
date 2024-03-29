import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_edit.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_upload.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_insert.dart';
import 'package:wordsmith_utils/models/ebook/ebook_parse.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class PublishScreenWidget extends StatefulWidget {
  const PublishScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _PublishScreenWidgetState();
}

class _PublishScreenWidgetState extends State<PublishScreenWidget> {
  final _logger = LogManager.getLogger("PublishScreen");
  late EbookProvider _ebookProvider;
  late EbookParse _parsedEbook;
  late TransferFile _epubFile;
  bool _hasParsed = false;

  void _getParsedEBook(EbookParse ebook, TransferFile file) async {
    setState(() {
      _parsedEbook = ebook;
      _epubFile = file;
      _hasParsed = !_hasParsed;
    });
  }

  void _submitEditedEBook(EbookInsert ebook) async {
    ProgressIndicatorDialog().show(context, text: "Publishing...");

    await _ebookProvider.postEBook(ebook, _epubFile).then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<Ebook>():
          _logger.info("Succesfully published ebook ${result.data.title}");
          Navigator.of(context).pop(true);
        case Failure<Ebook>():
          showErrorDialog(
              context: context, content: Text(result.exception.toString()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _ebookProvider = context.read<EbookProvider>();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Publish story",
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: !_hasParsed
          ? PublishUploadWidget(
              onUploadCallback: _getParsedEBook,
            )
          : PublishEditWidget(
              parsedEbook: _parsedEbook,
              onEditCallback: _submitEditedEBook,
            ),
    );
  }
}
