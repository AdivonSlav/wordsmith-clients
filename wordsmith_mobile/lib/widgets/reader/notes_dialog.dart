import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/models/note/note.dart';
import 'package:wordsmith_utils/models/note/note_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/note_provider.dart';

class NotesDialogWidget extends StatefulWidget {
  final int ebookId;
  final void Function(String cfi) onGoto;

  const NotesDialogWidget({
    super.key,
    required this.ebookId,
    required this.onGoto,
  });

  @override
  State<NotesDialogWidget> createState() => _NotesDialogWidgetState();
}

class _NotesDialogWidgetState extends State<NotesDialogWidget> {
  late NoteProvider _noteProvider;
  late Future<Result<QueryResult<Note>>> _notesFuture;

  Widget _buildContent() {
    return FutureBuilder(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late List<Note> notes;

        switch (snapshot.data!) {
          case Success(data: final d):
            notes = d.result;
          case Failure(exception: final e):
            return Center(
              child: Text(e.toString()),
            );
        }

        if (notes.isEmpty) {
          return const Text(
            "No notes. To add a note, long tap on a piece of text",
          );
        }

        var size = MediaQuery.of(context).size;
        return SizedBox(
          width: size.width,
          height: size.height * 0.5,
          child: ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              var note = notes[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "`${note.referencedText}`",
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                        child: Text(note.content),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // TextButton(
                          //   onPressed: () {
                          //     _dismiss();
                          //     widget.onGoto(note.cfi);
                          //   },
                          //   child: const Text("Go to"),
                          // ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      TextButton(
        onPressed: () => _dismiss(),
        child: const Text("Close"),
      ),
    ];
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  void _getNotes() {
    final userId = AuthProvider.loggedUser?.id;

    if (userId == null) {
      _notesFuture = Future.value(Failure(BaseException("Not logged in",
          type: ExceptionType.unauthorizedException)));
    }

    final search = NoteSearch(userId: userId, eBookId: widget.ebookId);
    _notesFuture = _noteProvider.getNotes(search);
  }

  @override
  void initState() {
    _noteProvider = context.read<NoteProvider>();
    _getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text("Notes"),
        actions: _buildActions(),
        content: _buildContent(),
      ),
    );
  }
}
