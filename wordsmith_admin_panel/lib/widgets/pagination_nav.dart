import "package:flutter/material.dart";

class PaginationNavWidget extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final void Function() backCallback;
  final void Function() forwardCallback;

  const PaginationNavWidget(
      {super.key,
      required this.currentPage,
      required this.lastPage,
      required this.backCallback,
      required this.forwardCallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: backCallback,
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          Text("$currentPage / $lastPage"),
          IconButton(
            onPressed: forwardCallback,
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }
}
