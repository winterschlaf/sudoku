import 'dart:math';

// all puzzle are displayed side by side
// e.g:
// 1 2 | 3 4    1 . | 3 4    1 2 | 3 4    1 . | 3 4    1 2 | 3 4    1 . | 3 4
// 5 6 | 7 8    . . | 6 .    5 6 | 7 8    . . | 6 .    5 6 | 7 8    . . | 6 .
// - - - - -    - - - - -    - - - - -    - - - - -    - - - - -    - - - - -
// . 1 | 2 3    7 6 | . 5    . 1 | 2 3    7 6 | . 5    . 1 | 2 3    7 6 | . 5
// 4 5 | 6 7    . . | . .    4 5 | 6 7    . . | . .    4 5 | 6 7    . . | . .
//
// or
//
// 1 7 . | . . 8 | . . 2    1 7 9 | 5 4 8 | 3 6 2
// 2 5 . | 7 . . | . . 8    2 5 4 | 7 3 6 | 1 9 8
// . . . | 9 1 . | . . 4    3 6 8 | 9 1 2 | 5 7 4
// - - - - - - - - - - -    - - - - - - - - - - -
// 4 8 3 | 6 . 5 | . 2 1    4 8 3 | 6 9 5 | 7 2 1
// . 2 5 | 4 . 1 | . . .    9 2 5 | 4 7 1 | 6 8 3
// . 1 . | . . 3 | . 5 .    7 1 6 | 8 2 3 | 4 5 9
// - - - - - - - - - - -    - - - - - - - - - - -
// . . 1 | . 5 4 | 8 3 .    6 9 1 | 2 5 4 | 8 3 7
// . . . | . 8 . | 9 . .    5 4 2 | 3 8 7 | 9 1 6
// . 3 7 | 1 6 . | . . .    8 3 7 | 1 6 9 | 2 4 5
String getVisualRepresentationSideBySide(
    List<List<int>> puzzles,
    int size,
    int x,
    int y,
    int quadrantX,
    int quadrantY,
    int emptyTile,
    String newLine,
    String inBetween,
    String paddingCharacter
    ) {
  List<String> visualRepresentation = [];

  for (List<int> puzzle in puzzles) {
    visualRepresentation
        .add(getVisualRepresentation(puzzle, size, x, y, quadrantX, quadrantY, emptyTile, newLine, paddingCharacter));
  }

  String str = '';

  for(int yy=0;yy<y + (y/quadrantY).round() - 1;yy++) {
    for(int j=0;j<visualRepresentation.length;j++) {
      str += j == 0
          ? ''
          : inBetween;
      str += visualRepresentation[j].split(newLine)[yy];
    }

    str += newLine;
  }

  return str;
}

String getVisualRepresentation(
    List<int> puzzle,
    int size,
    int x,
    int y,
    int quadrantX,
    int quadrantY,
    int emptyTile,
    String newLine,
    String paddingCharacter
    ) {
  String s = "";

  for(int yy=0;yy<y;yy++) {
    s += yy != 0 && yy % quadrantY == 0
        ? getHorizontalLine(x, quadrantX) + newLine
        : '';

    for(int xx=0;xx<x;xx++) {
      s += xx != 0 && xx % quadrantX == 0
          ? ' |'
          : '';
      s += xx != 0
          ? ' '
          : '';
      int value = puzzle[xx + yy * x];
      String strValue = value == emptyTile
          ? '.'
          : value.toString();
      strValue = strValue.padLeft(
        size.toString().length,
        value == emptyTile
            ? paddingCharacter != ' '
                ? '.'
                : ' '
            : paddingCharacter
      );

      s+= strValue;
    }

    s += newLine;
  }

  return s;
}

String getHorizontalLine(
    int x,
    int subSize
    ) {
  String line = '';

  for (int i = 0; i < x; i++) {
    if(i != 0 && i % subSize == 0) {
      line += '- ';
    }

    line += '-'.padLeft(x
        .toString()
        .length, '-') + ' ';
  }

  return line.trim();
}
