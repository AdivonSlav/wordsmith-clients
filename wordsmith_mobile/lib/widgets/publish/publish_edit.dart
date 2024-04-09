import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_chapters_view.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_genres.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_instructions.dart';
import 'package:wordsmith_mobile/widgets/publish/publish_maturity_ratings.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook_insert.dart';
import 'package:wordsmith_utils/models/ebook/ebook_parse.dart';
import 'package:wordsmith_utils/models/genre/genre.dart';
import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class PublishEditWidget extends StatefulWidget {
  final EbookParse parsedEbook;
  final void Function(EbookInsert ebook) onEditCallback;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

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

  final String _initialPriceValue = "0.01";
  final _currencyFormatter = CurrencyTextInputFormatter(
    symbol: "\$ ",
    locale: "en",
    decimalDigits: 2,
    maxValue: 100.00,
  );

  final bool _uploadInProgress = false;
  bool _enteringPrice = false;

  List<Genre> _selectedGenres = [];
  MaturityRating? _selectedMaturityRating;

  void _getSelectedGenres(List<Genre> genres) {
    _selectedGenres = genres;
    _logger.info("Got ${_selectedGenres.length} genres");
  }

  void _getSelectedMaturityRating(MaturityRating? maturityRating) {
    _selectedMaturityRating = maturityRating;
    _logger.info("Selected ${maturityRating?.name} maturity rating");
  }

  void _onSubmit() async {
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
        context: context,
        content: Text(validationErrors),
      );
      return;
    }

    double? price = _enteringPrice
        ? _currencyFormatter.getUnformattedValue().toDouble()
        : null;
    var authorId = AuthProvider.loggedUser!.id;
    var genreIds = _selectedGenres.map((e) => e.id).toList();

    var insert = EbookInsert(
        widget._titleController.text,
        widget._descriptionController.text.trim(),
        widget.parsedEbook.encodedCoverArt,
        widget.parsedEbook.chapters,
        price,
        authorId,
        genreIds,
        _selectedMaturityRating!.id);

    widget.onEditCallback(insert);
  }

  void _enterPriceEdit(bool? value) {
    if (value == null) return;

    setState(() {
      _enteringPrice = value;

      if (value) {
        widget._priceController.text =
            _currencyFormatter.format(_initialPriceValue);
      } else {
        widget._priceController.clear();
      }
    });
  }

  String? _validatePriceInput(String? value) {
    if (!_enteringPrice) return null;
    if (value == null || value.isEmpty) {
      return "You must enter a price";
    }

    var asNum = _currencyFormatter.getUnformattedValue();

    if (asNum == 0.0) {
      return "Price must be at least \$ $_initialPriceValue";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("Loaded ebook ${widget.parsedEbook.title} for editing");
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const PublishInstructionsWidget(),
            const SizedBox(
              height: 8.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EbookImageWidget(
                    width: size.width * 0.75,
                    height: size.height * 0.60,
                    fit: BoxFit.fill,
                    encodedCoverArt: widget.parsedEbook.encodedCoverArt,
                  ),
                  const SizedBox(
                    height: 32.0,
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
                    children: <Widget>[
                      Checkbox(
                        value: _enteringPrice,
                        onChanged: _enterPriceEdit,
                      ),
                      Text(
                        "Specify price",
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Visibility(
                    visible: _enteringPrice,
                    child: InputField(
                      labelText: "Price",
                      controller: widget._priceController,
                      obscureText: false,
                      textInputType: TextInputType.number,
                      validator: _validatePriceInput,
                      inputFormatters: <TextInputFormatter>[_currencyFormatter],
                    ),
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
