import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/publish_edit.dart';
import 'package:wordsmith_mobile/widgets/publish_upload.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_insert.dart';
import 'package:wordsmith_utils/models/ebook_parse.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class PublishScreenWidget extends StatefulWidget {
  const PublishScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _PublishScreenWidgetState();
}

class _PublishScreenWidgetState extends State<PublishScreenWidget> {
  final _logger = LogManager.getLogger("PublishScreen");
  late EBookProvider _ebookProvider;
  late EBookParse _parsedEbook;
  late TransferFile _epubFile;
  bool _hasParsed = false;

  void _getParsedEBook(EBookParse ebook, TransferFile file) async {
    setState(() {
      _parsedEbook = ebook;
      _epubFile = file;
      _hasParsed = !_hasParsed;
    });
  }

  void _submitEditedEBook(EBookInsert ebook) async {
    try {
      var result = await _ebookProvider.postEBook(ebook, _epubFile);

      if (context.mounted) {
        _logger.info("Succesfully published ebook ${result.title}");
        Navigator.of(context).pop(true);
      }
    } on BaseException catch (error) {
      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          Text(error.toString()),
        );
      }
      _logger.info(error);
    } on Exception catch (error) {
      _logger.severe(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ebookProvider = context.read<EBookProvider>();
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
