class Solver {
  List<int> puzzleOriginal = [];
  List<int> puzzleSolved = [];

  Solver() {
    //initial fill
    for(int i=0;i<9*9;i++) {
      puzzleOriginal.add(0);
      puzzleSolved.add(0);
    }
  }

  // returns the visual representation of the sudoku puzzle
  // how it should look like:
  // 3 . . | 6 . . | . 9 .
  // . 4 . | . 2 . | . 5 .
  // . 8 . | . 7 . | 1 6 .
  // - - - - - - - - - - -
  // 9 . . | 3 . 4 | 7 . .
  // . 5 . | . 8 . | . 2 .
  // . . 1 | 9 . . | . . 6
  // - - - - - - - - - - -
  // . 2 7 | . 3 . | . 4 .
  // . 9 . | . 6 . | . 1 .
  // . 3 . | . . 5 | . . 8
  String getVisualRepresentation(bool original) {
    String s = "";

    for(int y=0;y<9;y++) {
      s += y != 0 && y % 3 == 0 ? "- - - - - - - - - - -\n" : "";

      for(int x=0;x<9;x++) {
        s += x != 0 && x % 3 == 0 ? " |" : "";
        s += x != 0 ? " " : "";
        int value = original ? puzzleOriginal[x + y * 9] : puzzleSolved[x + y * 9];
        s += value == 0 ? "." : value.toString();
      }

      s+= "\n";
    }

    return s;
  }

  // returns the visual representation of the sudoku puzzle
  // both the original and solved puzzle, side by side
  // how it should look like:
  // 3 . . | 6 . . | . 9 .    3 . . | 6 . . | . 9 .
  // . 4 . | . 2 . | . 5 .    . 4 . | . 2 . | . 5 .
  // . 8 . | . 7 . | 1 6 .    . 8 . | . 7 . | 1 6 .
  // - - - - - - - - - - -    - - - - - - - - - - -
  // 9 . . | 3 . 4 | 7 . .    9 . . | 3 . 4 | 7 . .
  // . 5 . | . 8 . | . 2 .    . 5 . | . 8 . | . 2 .
  // . . 1 | 9 . . | . . 6    . . 1 | 9 . . | . . 6
  // - - - - - - - - - - -    - - - - - - - - - - -
  // . 2 7 | . 3 . | . 4 .    . 2 7 | . 3 . | . 4 .
  // . 9 . | . 6 . | . 1 .    . 9 . | . 6 . | . 1 .
  // . 3 . | . . 5 | . . 8    . 3 . | . . 5 | . . 8

  String getVisualRepresentationSideBySide() {
    String b = "";
    String o = getVisualRepresentation(true).replaceAll("\r", "");
    String s = getVisualRepresentation(false).replaceAll("\r", "");

    for(int i=0;i<(9 + 2); i++) {
      b += o.split("\n")[i];
      b += "    ";
      b += s.split("\n")[i];
      b += "\n";
    }

    return b;
  }
}