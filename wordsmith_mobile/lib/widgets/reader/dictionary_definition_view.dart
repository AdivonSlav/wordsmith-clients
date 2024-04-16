import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_entry.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_pronunciation.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_response.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/dictionary_provider.dart';

class DictionaryDefinitionViewWidget extends StatefulWidget {
  final String selectedText;

  const DictionaryDefinitionViewWidget({super.key, required this.selectedText});

  @override
  State<DictionaryDefinitionViewWidget> createState() =>
      _DictionaryDefinitionViewWidgetState();
}

class _DictionaryDefinitionViewWidgetState
    extends State<DictionaryDefinitionViewWidget> {
  late DictionaryProvider _dictionaryProvider;

  late Future<Result<DictionaryResponse>> _dictionaryResponseFuture;

  @override
  void initState() {
    _dictionaryProvider = context.read<DictionaryProvider>();
    _dictionaryResponseFuture =
        _dictionaryProvider.getDictionaryEntries(widget.selectedText);
    super.initState();
  }

  Widget _buildDictionaryEntries() {
    return FutureBuilder(
      future: _dictionaryResponseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late DictionaryResponse dictionaryResponse;

        switch (snapshot.data!) {
          case Success(data: final d):
            dictionaryResponse = d;
          case Failure(exception: final e):
            return Center(
              child: Text(e.toString()),
            );
        }

        if (dictionaryResponse.entries.isEmpty) {
          return const Center(child: Text("No definitions found"));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dictionaryResponse.entries.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                var entry = dictionaryResponse.entries[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildMainEntryInfo(entry),
                    _buildDefinitions(entry),
                    _buildEtymology(entry),
                    _buildDate(entry),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainEntryInfo(DictionaryEntry entry) {
    var pronuncations = entry.headword.pronunciations;
    String? headword = entry.headword.text;
    String guide = _constructPronuncationGuide(pronuncations);
    String? functionalLabel = entry.functionalLabel;

    return Text.rich(
      TextSpan(
        text: headword,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17.0,
        ),
        children: [
          if (headword != null && headword.isNotEmpty)
            const TextSpan(text: "  "),
          TextSpan(
            text: guide,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 11.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (guide.isNotEmpty) const TextSpan(text: "  "),
          TextSpan(
            text: functionalLabel,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
              fontStyle: FontStyle.normal,
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  String _constructPronuncationGuide(
      List<DictionaryPronunciation> pronuncations) {
    var guides = "";

    if (pronuncations.length > 1) {
      guides =
          "/${pronuncations.map((e) => e.writtenPronunciation).join(", ")}/";
    } else if (pronuncations.length == 1) {
      guides = "/${pronuncations.first.writtenPronunciation}/";
    }

    return guides;
  }

  Widget _buildDefinitions(DictionaryEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Definitions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entry.shortDefs.map<Widget>((e) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u2022',
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Text(
                        e,
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtymology(DictionaryEntry entry) {
    if (entry.etymology == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Etymology",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          Html(data: entry.etymology),
        ],
      ),
    );
  }

  Widget _buildDate(DictionaryEntry entry) {
    if (entry.date == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "First known use",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(entry.date ?? ""),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Dictionary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          const Divider(height: 15.0),
          Expanded(
            child: Builder(
              builder: (context) => _buildDictionaryEntries(),
            ),
          ),
        ],
      ),
    );
  }
}
