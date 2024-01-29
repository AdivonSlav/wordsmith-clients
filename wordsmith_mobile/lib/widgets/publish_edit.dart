import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_mobile/widgets/publish_chapters_view.dart';
import 'package:wordsmith_mobile/widgets/publish_genres.dart';
import 'package:wordsmith_mobile/widgets/publish_instructions.dart';
import 'package:wordsmith_mobile/widgets/publish_maturity_ratings.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_insert.dart';
import 'package:wordsmith_utils/models/ebook_parse.dart';
import 'package:wordsmith_utils/models/genre.dart';
import 'package:wordsmith_utils/models/maturity_rating.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class PublishEditWidget extends StatefulWidget {
  final EBookParse parsedEbook;
  final void Function(EBookInsert ebook) onEditCallback;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  PublishEditWidget({
    super.key,
    required this.parsedEbook,
    required this.onEditCallback,
  }) {
    _titleController.text = parsedEbook.title;
    _descriptionController.text = parsedEbook.description;
  }

  @override
  State<StatefulWidget> createState() => _PublishEditWidgetState();
}

class _PublishEditWidgetState extends State<PublishEditWidget> {
  final _logger = LogManager.getLogger("PublishEditWidget");
  final _formKey = GlobalKey<FormState>();

  final _titleMaxLength = 40;
  final _descriptionMaxLength = 800;

  var _uploadInProgress = false;

  List<Genre> _selectedGenres = [];
  MaturityRating? _selectedMaturityRating;

  void _getSelectedGenres(List<Genre> genres) {
    setState(() {
      _selectedGenres = genres;
      _logger.info("Got ${_selectedGenres.length} genres");
    });
  }

  void _getSelectedMaturityRating(MaturityRating? maturityRating) {
    setState(() {
      _selectedMaturityRating = maturityRating;
      _logger.info("Selected ${maturityRating?.name} maturity rating");
    });
  }

  void _toggleUploadInProgress() {
    setState(() {
      _uploadInProgress = !_uploadInProgress;
    });
  }

  void _onSubmit() async {
    if (_uploadInProgress == true) {
      return;
    }

    _toggleUploadInProgress();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    var validationErrors = "";

    if (_selectedGenres.isEmpty) {
      validationErrors += "You must select at least one genre!\n";
    }
    if (_selectedMaturityRating == null) {
      validationErrors += "You must select at least one maturity rating!\n";
    }

    if (validationErrors.isNotEmpty) {
      await showErrorDialog(
        context,
        const Text("Error"),
        Text(validationErrors),
      );
      return;
    }

    _uploadInProgress = true;

    var authorId = AuthProvider.loggedUser!.id;
    var genreIds = _selectedGenres.map((e) => e.id).toList();
    var insert = EBookInsert(
        widget._titleController.text,
        widget._descriptionController.text.trim(),
        widget.parsedEbook.encodedCoverArt,
        widget.parsedEbook.chapters,
        null, // TODO: Pass when payment system is implemented
        authorId,
        genreIds,
        _selectedMaturityRating!.id);

    widget.onEditCallback(insert);
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("Loaded ebook ${widget.parsedEbook.title} for editing");

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  Column(
                    children: [
                      InputField(
                        labelText: "Title",
                        controller: widget._titleController,
                        obscureText: false,
                        maxLines: 1,
                        maxLength: _titleMaxLength,
                        validator: validateEBookTitle,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      InputField(
                        labelText: "Description",
                        controller: widget._descriptionController,
                        obscureText: false,
                        maxLines: 15,
                        maxLength: _descriptionMaxLength,
                        validator: validateEBookDescription,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  PublishGenresWidget(
                    onGenreSelect: _getSelectedGenres,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  PublishMaturityRatingsWidget(
                    onMaturityRatingSelect: _getSelectedMaturityRating,
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
                        onPressed: _onSubmit,
                        child: !_uploadInProgress
                            ? const Text("Submit")
                            : const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(),
                              ),
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
