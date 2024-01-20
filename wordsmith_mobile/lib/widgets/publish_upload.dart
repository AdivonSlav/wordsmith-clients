import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/epub_helper.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_parse.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/size_config.dart';

class PublishUploadWidget extends StatelessWidget {
  final void Function(EBookParse ebook) onUploadCallback;

  const PublishUploadWidget({
    super.key,
    required this.onUploadCallback,
  });

  @override
  Widget build(BuildContext context) {
    final logger = LogManager.getLogger("PublishUploadWidget");
    final eBookParseProvider = context.read<EBookParseProvider>();
    final userLoginProvider = context.read<UserLoginProvider>();

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
                  onPressed: () async {
                    var file = await EpubHelper.pickEpub();

                    if (file != null) {
                      var transferFile = await EpubHelper.verify(file);

                      if (transferFile == null) {
                        if (context.mounted) {
                          await showErrorDialog(
                            context,
                            const Text("Failure"),
                            const Text(
                                "You must upload an EPUB file that is 10MB or  less"),
                          );
                        }
                      } else {
                        try {
                          var parsedEpub =
                              await eBookParseProvider.getParsed(transferFile);

                          logger.info("Got parsed ebook ${parsedEpub.title}");

                          onUploadCallback(parsedEpub);
                        } on BaseException catch (error) {
                          if (context.mounted) {
                            await showErrorDialog(
                              context,
                              const Text("Failure"),
                              Text(error.toString()),
                            );
                          }
                        }
                      }
                    }
                  },
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
