import 'package:flutter/material.dart';

import '../../models/Chip.dart';
import '../../models/Player.dart';
import '../../components/Chips.dart';
import 'DropButton.dart';


class Board extends StatefulWidget {
  final Player1 player1;
  final Player2 player2;

  Board(this.player1, this.player2);

  @override
  _BoardState createState() => _BoardState(player1, player2);
}

class _BoardState extends State<Board> {
  static const DIAGONAL_DOWN = 'diagonalDown';
  static const DIAGONAL_UP = 'diagonalUp';
  static const HORIZONTAL = 'horizontal';
  static const VERTICAL = 'vertical';

  final Player1 player1;
  final Player2 player2;

  int currentPlayer = 1;
  List<bool> showDrops = [true, true, true, true, true, true, true];
  List nodes = List.generate(7, (int index) {
    return List.generate(6, (int jIndex) {
      return new ChipNode(index, jIndex, Colors.white);
    }, growable: false);
  }, growable: false);

  _BoardState(this.player1, this.player2);

  void disableDropButtons () {
    setState(() {
      showDrops = [false, false, false, false, false, false, false];
    });
  }

  int findLength(String pId, int length, ChipNode prevNode, String dir) {
    if (length < 4) {
      if (dir == DIAGONAL_DOWN) {
        if (prevNode.x - 1 >= 0 && prevNode.y + 1 < 6 && nodes[prevNode.x - 1][prevNode.y + 1].pId == pId) {
          return findLength(pId, length + 1, nodes[prevNode.x - 1][prevNode.y + 1], dir);
        }
      }
      if (dir == DIAGONAL_UP) {
        if (prevNode.x + 1 < 7 && prevNode.y + 1 < 6 && nodes[prevNode.x + 1][prevNode.y + 1].pId == pId) {
          return findLength(pId, length + 1, nodes[prevNode.x + 1][prevNode.y + 1], dir);
        }
      }
      if (dir == HORIZONTAL) {
        if (prevNode.x + 1 < 7 && nodes[prevNode.x + 1][prevNode.y].pId == pId) {
          return findLength(pId, length + 1, nodes[prevNode.x + 1][prevNode.y], dir);
        }
      }
      if (dir == VERTICAL) {
        if (prevNode.y + 1 < 6 && nodes[prevNode.x][prevNode.y + 1].pId == pId) {
          return findLength(pId, length + 1, nodes[prevNode.x][prevNode.y + 1], dir);
        }
      }
    }
    return length;
  }

  void insertPlayerChip(int column) {
    setState(() {
      for (int y = 0; y < 6; y++) {
        if (nodes[column][y].pId == null) {
          setState(() {
            nodes[column][y] = new ChipNode.withPlayer(
              column,
              y,
              currentPlayer == 1 ? player1.pId : player2.pId,
              currentPlayer == 1 ? player1.color : player2.color,
            );
          });
          break;
        }
      }
    });
  }

  bool isColumnFull(column) {
    return nodes[column][5].pId != null;
  }

  bool isWinner(String pId, int length) {
    bool isWinner = false;
    for (int y = 0; y < 6; y++) {
      for (int x = 0; x < 7; x++) {
        if (nodes[x][y].pId == pId && (
          findLength(pId, 1, nodes[x][y], DIAGONAL_DOWN) == 4 ||
          findLength(pId, 1, nodes[x][y], DIAGONAL_UP) == 4 ||
          findLength(pId, 1, nodes[x][y], HORIZONTAL) == 4 ||
          findLength(pId, 1, nodes[x][y], VERTICAL) == 4
        )) {
          isWinner = true;
          break;
        }
      }
      if (isWinner) {
        break;
      }
    }
    return isWinner;
  }

  void runGameLoop(column) {
    // turn off all drops
    disableDropButtons();
    // insert new chip
    insertPlayerChip(column);
    // check if player is a winner
    if (isWinner(currentPlayer == 1 ? player1.pId : player2.pId, 0)) {
      print("show winner card (not created yet)");
    } else {
      // check if board is full
      if (
        isColumnFull(0) && isColumnFull(1) &&
        isColumnFull(2) && isColumnFull(3) &&
        isColumnFull(4) && isColumnFull(5) &&
        isColumnFull(6)
      ) {
        print("Show Draw Card");
      } else {
        // set currentPlayer to the other player
        setState(() {
          currentPlayer = currentPlayer == 1 ? 2 : 1;
        });
        // enable valid columns
        setState(() {
          showDrops = [
            !isColumnFull(0), !isColumnFull(1),
            !isColumnFull(2), !isColumnFull(3),
            !isColumnFull(4), !isColumnFull(5),
            !isColumnFull(6)
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            for(int i = 0; i < 7; i++) DropButton(showDrops[i], () { runGameLoop(i); })
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            ColorChip(UniqueKey(), nodes[0][5].color, null),
            ColorChip(UniqueKey(), nodes[1][5].color, null),
            ColorChip(UniqueKey(), nodes[2][5].color, null),
            ColorChip(UniqueKey(), nodes[3][5].color, null),
            ColorChip(UniqueKey(), nodes[4][5].color, null),
            ColorChip(UniqueKey(), nodes[5][5].color, null),
            ColorChip(UniqueKey(), nodes[6][5].color, null),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: <Widget>[
            ColorChip(UniqueKey(), nodes[0][4].color, null),
            ColorChip(UniqueKey(), nodes[1][4].color, null),
            ColorChip(UniqueKey(), nodes[2][4].color, null),
            ColorChip(UniqueKey(), nodes[3][4].color, null),
            ColorChip(UniqueKey(), nodes[4][4].color, null),
            ColorChip(UniqueKey(), nodes[5][4].color, null),
            ColorChip(UniqueKey(), nodes[6][4].color, null),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: [
            ColorChip(UniqueKey(), nodes[0][3].color, null),
            ColorChip(UniqueKey(), nodes[1][3].color, null),
            ColorChip(UniqueKey(), nodes[2][3].color, null),
            ColorChip(UniqueKey(), nodes[3][3].color, null),
            ColorChip(UniqueKey(), nodes[4][3].color, null),
            ColorChip(UniqueKey(), nodes[5][3].color, null),
            ColorChip(UniqueKey(), nodes[6][3].color, null),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: [
            ColorChip(UniqueKey(), nodes[0][2].color, null),
            ColorChip(UniqueKey(), nodes[1][2].color, null),
            ColorChip(UniqueKey(), nodes[2][2].color, null),
            ColorChip(UniqueKey(), nodes[3][2].color, null),
            ColorChip(UniqueKey(), nodes[4][2].color, null),
            ColorChip(UniqueKey(), nodes[5][2].color, null),
            ColorChip(UniqueKey(), nodes[6][2].color, null),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: [
            ColorChip(UniqueKey(), nodes[0][1].color, null),
            ColorChip(UniqueKey(), nodes[1][1].color, null),
            ColorChip(UniqueKey(), nodes[2][1].color, null),
            ColorChip(UniqueKey(), nodes[3][1].color, null),
            ColorChip(UniqueKey(), nodes[4][1].color, null),
            ColorChip(UniqueKey(), nodes[5][1].color, null),
            ColorChip(UniqueKey(), nodes[6][1].color, null),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: [
            ColorChip(UniqueKey(), nodes[0][0].color, null),
            ColorChip(UniqueKey(), nodes[1][0].color, null),
            ColorChip(UniqueKey(), nodes[2][0].color, null),
            ColorChip(UniqueKey(), nodes[3][0].color, null),
            ColorChip(UniqueKey(), nodes[4][0].color, null),
            ColorChip(UniqueKey(), nodes[5][0].color, null),
            ColorChip(UniqueKey(), nodes[6][0].color, null),
          ],
        ),
      ],
    );
  }
}