import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_mobile/widgets/publish_chapters_view.dart';
import 'package:wordsmith_mobile/widgets/publish_instructions.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_parse.dart';
import 'package:wordsmith_utils/size_config.dart';

class PublishEditWidget extends StatefulWidget {
  final EBookParse parsedEbook;
  final void Function(EBookParse ebook) onEditCallback;

  const PublishEditWidget({
    super.key,
    required this.parsedEbook,
    required this.onEditCallback,
  });

  @override
  State<StatefulWidget> createState() => _PublishEditWidgetState();
}

class _PublishEditWidgetState extends State<PublishEditWidget> {
  final _logger = LogManager.getLogger("PublishEditWidget");
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _titleMaxLength = 40;
  final _descriptionMaxLength = 800;

  @override
  Widget build(BuildContext context) {
    _logger.info("Loaded ebook ${widget.parsedEbook.title} for editing");
    var parsedEbookEdit = widget.parsedEbook;

    _titleController.text = parsedEbookEdit.title;
    _descriptionController.text = parsedEbookEdit.description;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const PublishInstructionsWidget(),
            const SizedBox(
              height: 32.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EBookImageWidget(
                      encodedCoverArt: widget.parsedEbook.encodedCoverArt),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputField(
                    labelText: "Title",
                    controller: _titleController,
                    obscureText: false,
                    maxLength: _titleMaxLength,
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InputField(
                    labelText: "Description",
                    controller: _descriptionController,
                    obscureText: false,
                    maxLength: _descriptionMaxLength,
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PublishChaptersView(
                          chapters: widget.parsedEbook.chapters),
                      SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 8.0,
                      ),
                      FilledButton(
                        onPressed: () {
                          widget.onEditCallback(parsedEbookEdit);
                        },
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
