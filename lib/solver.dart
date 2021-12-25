import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Solver {
  List<int> puzzleOriginal = [];
  List<int> puzzleSolved = [];
  Stopwatch stopwatch = Stopwatch();
  int iterations = 0;

  Solver() {
    clear();
  }

  // loads puzzle from assets via its path
  // e.g. assets/sudoku/easy-001.txt
  Future<bool> loadFromAssets(String path) async {
    loadFromString(await rootBundle.loadString(path));
    return true;
  }

  // loads a puzzle from string,
  // each line has exactly 9 characters
  // a dot, zero or blank represents unknown numbers
  // e.g. 17...8..225.7....8...91...44836.5.21.254.1....1...3.5...1.5483.....8.9...3716....
  void loadFromString(String? puzzle) {
    if (puzzle == null || puzzle.trim().isEmpty) {
      throw Exception("empty/blank puzzles are not allowed");
    }

    puzzle = puzzle
        .replaceAll("\r", "")
        .replaceAll("\n", "")
        .replaceAll("\.", "0")
        .replaceAll(" ", "0")
    ;

    if (puzzle.length != 9*9) {
      throw Exception("puzzle has to contain exactly ${9*9} characters, found ${puzzle.length} characters");
    }

    clear();

    for(int i=0;i<9*9;i++) {
      puzzleSolved[i] = int.parse(puzzle[i]);
      puzzleOriginal[i] = int.parse(puzzle[i]);
    }
  }

  void clear() {
    iterations = 0;
    stopwatch.stop();

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

  String getStatistics() {
    return "time: ${stopwatch.elapsedMilliseconds}ms, iterations: ${iterations}";
  }
}