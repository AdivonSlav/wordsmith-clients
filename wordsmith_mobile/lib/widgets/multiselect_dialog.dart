import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/size_config.dart';

class MultiSelectDialogWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectDialogWidget({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
  });

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogWidgetState();
}

class _MultiSelectDialogWidgetState extends State<MultiSelectDialogWidget> {
  late List<String> _filteredList;
  final _searchGenreController = TextEditingController(text: "");

  void _itemChange(String itemValue, bool selected) {
    setState(() {
      if (selected) {
        widget.selectedItems.add(itemValue);
      } else {
        widget.selectedItems.remove(itemValue);
      }
    });
  }

  void _itemSearch(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _filteredList = List.from(widget.items);
      } else {
        _filteredList = widget.items
            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredList = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField(
            labelText: "Search",
            controller: _searchGenreController,
            obscureText: false,
            onChangedCallback: _itemSearch,
          ),
          const Divider(
            height: 20.0,
          ),
          Flexible(
            child: SizedBox(
              height: SizeConfig.safeBlockVertical * 40.0,
              child: SingleChildScrollView(
                child: Card(
                  child: ListBody(
                    children: _filteredList
                        .map((item) => CheckboxListTile(
                              value: widget.selectedItems.contains(item),
                              title: Text(item),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (isChecked) =>
                                  _itemChange(item, isChecked!),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.selectedItems);
          },
          child: const Text("OK"),
        )
      ],
    );
  }
}
