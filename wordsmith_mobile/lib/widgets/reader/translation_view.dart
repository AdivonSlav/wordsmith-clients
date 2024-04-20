import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/translate/language.dart';
import 'package:wordsmith_utils/models/translate/translation_request.dart';
import 'package:wordsmith_utils/models/translate/translation_response.dart';
import 'package:wordsmith_utils/providers/translation_language_provider.dart';
import 'package:wordsmith_utils/providers/translation_provider.dart';

class TranslationViewWidget extends StatefulWidget {
  final String selectedText;

  const TranslationViewWidget({super.key, required this.selectedText});

  @override
  State<TranslationViewWidget> createState() => _TranslationViewWidgetState();
}

class _TranslationViewWidgetState extends State<TranslationViewWidget> {
  late TranslationProvider _translationProvider;
  late TranslationLanguageProvider _translationLanguageProvider;

  late Future<Result<QueryResult<Language>>> _languagesFuture;

  Language? _sourceLanguage;
  Language? _targetLanguage;

  String? _translation;
  bool _isTranslating = false;

  Widget _buildLanguageSelection(BoxConstraints constraints) {
    return FutureBuilder(
      future: _languagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late List<Language> languages;

        switch (snapshot.data!) {
          case Success(data: final d):
            languages = d.result;
          case Failure(exception: final e):
            return Center(
              child: Text(e.toString()),
            );
        }

        if (languages.isEmpty) {
          return const Center(
            child: Text("Could not translate"),
          );
        }

        _targetLanguage ??= languages.first;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              width: constraints.maxWidth * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("From:"),
                  DropdownButton(
                    isExpanded: true,
                    items: _constructSourceLanguageDropdownItems(languages),
                    value: _sourceLanguage,
                    onChanged: (language) {
                      setState(() {
                        _sourceLanguage = language;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("To:"),
                  DropdownButton(
                    isExpanded: true,
                    items: _constructTargetLanguageDropdownItems(languages),
                    value: _targetLanguage,
                    onChanged: (language) {
                      if (language != null) {
                        setState(() {
                          _targetLanguage = language;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranslatedText() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: _isTranslating
              ? const Text("Translating...")
              : Text(_translation ?? ""),
        ),
      ),
    );
  }

  Widget _buildTranslation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: constraints.maxHeight * 0.20,
              child: Builder(
                  builder: (context) => _buildLanguageSelection(constraints)),
            ),
            TextButton(
                onPressed: () => _getTranslation(),
                child: const Text("Translate")),
            SizedBox(
              width: double.infinity,
              height: constraints.maxHeight * 0.65,
              child: Builder(builder: (context) => _buildTranslatedText()),
            )
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<Language?>> _constructSourceLanguageDropdownItems(
      List<Language> languages) {
    return [null, ...languages].map<DropdownMenuItem<Language?>>((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e?.name ?? "Auto detect"),
      );
    }).toList();
  }

  List<DropdownMenuItem<Language>> _constructTargetLanguageDropdownItems(
      List<Language> languages) {
    return languages.map<DropdownMenuItem<Language>>((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e.name),
      );
    }).toList();
  }

  void _getTranslation() async {
    if (_isTranslating || _targetLanguage == null) return;
    _toggleIsTranslating();

    final request = TranslationRequest(
      text: widget.selectedText,
      targetLanguageCode: _targetLanguage!.languageCode,
      sourceLanguageCode: _sourceLanguage?.languageCode,
    );

    await _translationProvider.getTranslation(request).then((result) {
      _toggleIsTranslating();
      switch (result) {
        case Success<TranslationResponse>():
          setState(() {
            _translation = result.data.translation;
          });
        case Failure<TranslationResponse>():
          setState(() {
            _translation = result.exception.message;
          });
      }
    });
  }

  void _getSupportedLanguages() {
    _languagesFuture = _translationLanguageProvider.getSupportedLanguages();
  }

  void _toggleIsTranslating() {
    setState(() {
      _isTranslating = !_isTranslating;
    });
  }

  @override
  void initState() {
    _translationProvider = context.read<TranslationProvider>();
    _translationLanguageProvider = context.read<TranslationLanguageProvider>();
    _getSupportedLanguages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            "Translate",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          const Divider(height: 15.0),
          Expanded(
            child: Builder(
              builder: (context) => _buildTranslation(),
            ),
          )
        ],
      ),
    );
  }
}
