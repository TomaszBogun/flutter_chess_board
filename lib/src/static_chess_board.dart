import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../flutter_chess_board.dart';

class StaticChessBoard extends StatefulWidget{
  /// An instance of [ChessBoardController] which holds the game and allows
  /// manipulating the board programmatically.
  final ChessBoardController controller;

  /// Size of chessboard
  final double? size;

  /// A boolean which checks if the user should be allowed to make moves
  final bool enableUserMoves;

  final bool showBoardNumberAndLetters;

  /// The color type of the board
  final BoardColor boardColor;

  final PlayerColor boardOrientation;

  final VoidCallback? onMove;

  final VoidCallback? beforeMove;

  final bool highlightLastMoveSquares;

  final dynamic highlightLastMoveSquaresColor;

  const StaticChessBoard({
    Key? key,
    required this.controller,
    this.size,
    this.showBoardNumberAndLetters = false,
    this.enableUserMoves = true,
    this.boardColor = BoardColor.brown,
    this.boardOrientation = PlayerColor.white,
    this.onMove,
    this.beforeMove,
    this.highlightLastMoveSquares = true,
    required this.highlightLastMoveSquaresColor,
  }) : super(key: key);

  @override
  State<StaticChessBoard> createState() => _StaticChessboardState();
}


class _StaticChessboardState extends State<StaticChessBoard> {
  bool deferImagesLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    verifyRecommendedDeferredLoading();
  }

  void verifyRecommendedDeferredLoading() {
    if (!mounted) return;

    if (Scrollable.recommendDeferredLoadingForContext(context)) {
      deferImagesLoading = true;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() => verifyRecommendedDeferredLoading());
      });
    } else {
      setState(() => deferImagesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    FromToMove? squaresToHighlight = null;
    if(widget.highlightLastMoveSquares){
      squaresToHighlight = getSquaresToHighlight(widget.controller, widget.boardOrientation);
    }

    final boardImage = SizedBox.square(
      dimension: widget.size,
      child: getBoardImage(widget.boardColor),
    );


    final board = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          // board background
          boardImage,

          // to & from square highlighter
          if(squaresToHighlight != null && widget.highlightLastMoveSquares) Container(
            width: widget.size!,
            height: widget.size,
            child: Stack(
              children: [
                Positioned(
                  left: squaresToHighlight.fromX * (widget.size!/8),
                  bottom: squaresToHighlight.fromY * (widget.size!/8),
                  child: Container(
                    color: widget.highlightLastMoveSquaresColor.withOpacity(0.45),
                    width: widget.size!/8,
                    height: widget.size!/8,
                  ),
                ),
                Positioned(
                  left: squaresToHighlight.toX * (widget.size!/8),
                  bottom: squaresToHighlight.toY * (widget.size!/8),
                  child: Container(
                    color: widget.highlightLastMoveSquaresColor.withOpacity(0.45),
                    width: widget.size!/8,
                    height: widget.size!/8,
                  ),
                ),
              ],
            ),
          ),

          // actual pieces
          if (!deferImagesLoading)
            SizedBox(height: 0,) // TODO: pieces go here
        ],
      ),
    );


    return board;
  }

}


