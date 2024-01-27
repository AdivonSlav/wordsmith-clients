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

class PublishEditWidget extends StatefulWidget {
  final EBookParse parsedEbook;
  final void Function(EBookInsert ebook) onEditCallback;

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

  void _onSubmit() async {
    if (_selectedGenres.isEmpty) {
      await showErrorDialog(
        context,
        const Text("Error"),
        const Text("You must select at least one genre"),
      );
      return;
    }
    if (_selectedMaturityRating == null) {
      await showErrorDialog(
        context,
        const Text("Error"),
        const Text("You must select at least one maturity rating"),
      );
      return;
    }

    var authorId = AuthProvider.loggedUser!.id;
    var genreIds = _selectedGenres.map((e) => e.id).toList();
    var insert = EBookInsert(
        widget.parsedEbook.title,
        widget.parsedEbook.description,
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

    _titleController.text = widget.parsedEbook.title;
    _descriptionController.text = widget.parsedEbook.description;

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
