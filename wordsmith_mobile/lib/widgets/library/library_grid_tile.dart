import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';

class LibraryGridTileWidget extends StatefulWidget {
  final UserLibrary libraryEntry;
  final int tileIndex;
  final bool isSelected;
  final bool isSelectingBooks;
  final void Function(int index, int ebookId) onBookTap;
  final void Function(int index, int ebookId) onBookLongPress;

  const LibraryGridTileWidget({
    super.key,
    required this.libraryEntry,
    required this.tileIndex,
    required this.isSelected,
    required this.isSelectingBooks,
    required this.onBookTap,
    required this.onBookLongPress,
  });

  @override
  State<LibraryGridTileWidget> createState() => _LibraryGridTileWidgetState();
}

class _LibraryGridTileWidgetState extends State<LibraryGridTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  void _animateTile() {
    if (_animationController.isDismissed ||
        _animationController.status == AnimationStatus.reverse) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onBookTap() {
    widget.onBookTap(widget.tileIndex, widget.libraryEntry.id);
    if (widget.isSelectingBooks) {
      _animateTile();
    }
  }

  void _onBookLongPress() {
    widget.onBookLongPress(widget.tileIndex, widget.libraryEntry.id);
    if (!widget.isSelectingBooks) {
      _animateTile();
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation =
        Tween<double>(begin: 0.0, end: 2.0).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (!widget.isSelectingBooks) {
      _animationController.reverse();
    }

    return GridTile(
      child: GestureDetector(
        onTap: () => _onBookTap(),
        onLongPress: () => _onBookLongPress(),
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _animation.value,
                    sigmaY: _animation.value,
                  ),
                  child: EBookImageWidget(
                    width: size.width,
                    height: size.height,
                    coverArtUrl: widget.libraryEntry.eBook.coverArt.imagePath,
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: widget.isSelected,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Icon(
                      Icons.check_circle,
                      size: constraints.maxWidth * 0.4,
                      color: Colors.white,
                      shadows: const <Shadow>[
                        Shadow(
                          color: Colors.black,
                          blurRadius: 15.0,
                        ),
                        Shadow(
                          color: Colors.black,
                          blurRadius: 15.0,
                        )
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
