import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/epub_helper.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook_parse.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';
import 'package:wordsmith_utils/size_config.dart';

class PublishUploadWidget extends StatelessWidget {
  final void Function(EBookParse ebook, TransferFile file) onUploadCallback;

  const PublishUploadWidget({
    super.key,
    required this.onUploadCallback,
  });

  @override
  Widget build(BuildContext context) {
    final logger = LogManager.getLogger("PublishUploadWidget");
    final eBookParseProvider = Provider.of<EBookParseProvider>(context);

    void uploadForParsing() async {
      var file = await EpubHelper.pickEpub();

      if (file != null) {
        var transferFile = await EpubHelper.verify(file);

        if (transferFile == null) {
          if (context.mounted) {
            await showErrorDialog(
              context: context,
              content: const Text(
                  "You must upload an EPUB file that is 10MB or  less"),
            );
            return;
          }
        } else {
          await eBookParseProvider.getParsed(transferFile).then((result) {
            switch (result) {
              case Success<EBookParse>():
                logger.info("Got parsed ebook ${result.data.title}");
                onUploadCallback(result.data, transferFile);
              case Failure<EBookParse>():
                showErrorDialog(
                  context: context,
                  content: Text(result.exception.toString()),
                );
            }
          });
        }
      }
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 18.0,
                height: SizeConfig.safeBlockVertical * 9.0,
                child: IconButton.filled(
                  onPressed: uploadForParsing,
                  icon: const Icon(Icons.upload),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text("Upload your EPUB file to get started!"),
            ],
          )
        ],
      ),
    );
  }
}
