import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chess_board/classes/BoardPieceForStaticChessBoard.dart';
import '../chess/chess.dart' as c;
import '../flutter_chess_board.dart';
import '../functions/functions.dart';
import '../sharedWidgets/getBoardBorderWidget.dart';
import '../sharedWidgets/getBoardNumberAndLettersWidget.dart';

class StaticChessBoard extends StatefulWidget{
  /// An instance of [ChessBoardController] which holds the game and allows
  /// manipulating the board programmatically.
  final c.Chess chessGame;

  /// Size of chessboard
  final double? size;

  /// The color type of the board
  final BoardColor boardColor;
  final Color borderColor; // used for drawing red or green border on incorrect or correct move while training

  final bool showBoardNumberAndLetters;

  final PlayerColor boardOrientation;

  const StaticChessBoard({
    Key? key,
    required this.chessGame,
    this.showBoardNumberAndLetters = false,
    this.size,
    this.boardOrientation = PlayerColor.white,
    // colors
    this.boardColor = BoardColor.brown,
    this.borderColor = const Color(0x00ffffff),
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
    final boardImage = getBoardWidget(widget.boardColor);
    final board = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          // board background
          SizedBox.square(
            dimension: widget.size,
            child: boardImage,
          ),

          getBoardBorderWidget(widget.size!, widget.borderColor),

          // actual pieces
          if (!deferImagesLoading)
            AspectRatio(
              aspectRatio: 1.0,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) {
                  var row = index ~/ 8;
                  var column = index % 8;
                  var boardRank = widget.boardOrientation == PlayerColor.black ? '${row + 1}' : '${(7 - row) + 1}';
                  var boardFile = widget.boardOrientation == PlayerColor.white ? '${files[column]}' : '${files[7 - column]}';
                  var squareName = '$boardFile$boardRank';
                  var piece = BoardPieceForStaticChessBoard(squareName: squareName, game: widget.chessGame);
                  return piece;
                },
                itemCount: 64,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),

          getBoardNumberAndLettersWidget(widget. showBoardNumberAndLetters, widget.boardOrientation, widget.size!, widget.boardColor),

        ],
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: board
    );
  }
}
