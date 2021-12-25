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

  Future<bool> solve() async {
    stopwatch.start();
    fillInObvious();
    stopwatch.stop();
    return isSolved();
  }

  // tries to fill in all obvious numbers
  // iterate until no new number was set
  void fillInObvious() {
    bool changed = true;

    while(changed) {
      iterations++;
      changed = false;

      for(int y=0;y<9;y++) {
        for(int x=0;x<9;x++) {
          //skip any number already filled in, zero means it is not filled!
          if(puzzleSolved[x + y * 9] == 0) {
            List<int> potentialNumbers = [1,2,3,4,5,6,7,8,9];
            //remove all numbers that are already used horizontally
            potentialNumbers.removeWhere((element) => getHorizontalNumbers(puzzleSolved, y).contains(element));
            //remove all numbers that are already used vertically
            potentialNumbers.removeWhere((element) => getVerticalNumbers(puzzleSolved, x).contains(element));
            //remove all numbers that are already used in the current quadrant
            potentialNumbers.removeWhere((element) => getQuadrantNumbers(puzzleSolved, x, y).contains(element));
            //remove all numbers which can be used on multiple tiles in the current quadrant
            potentialNumbers.removeWhere((element) => getAmbiguousQuadrantNumbers(puzzleSolved, potentialNumbers, x, y).contains(element));

            // if only one number is left, use it
            if(potentialNumbers.length == 1) {
              puzzleSolved[x + y * 9] = potentialNumbers[0];
              changed = true;
            }
          }
        }
      }
    }
  }

  bool isSolved() {
    bool solved = true;

    for(int i=0;i<9*9 && solved;i++) {
      solved = puzzleSolved[i] != 0;
    }

    return solved;
  }

  // returns a list of numbers that can be used on multiple tiles
  List<int> getAmbiguousQuadrantNumbers(List<int> puzzle, List<int> potentialNumbers, int x, int y) {
    List<int> list = [];
    int offsetX = ((x - x%3)/3).round();
    int offsetY = ((y - y%3)/3).round();

    for(int e=potentialNumbers.length;e>0;e--) {
      int value = potentialNumbers[e-1];
      int possiblePlaces = 0;

      for (int yy = 0; yy < 3; yy++) {
        for (int xx = 0; xx < 3; xx++) {
          if(puzzle[xx + offsetX * 3 + (yy + offsetY * 3) * 9] == 0) {
            possiblePlaces += (
                !getHorizontalNumbers(puzzle, yy + offsetY * 3).contains(value)
                && !getVerticalNumbers(puzzle, xx + offsetX * 3).contains(value)
            )
                ? 1
                : 0;
          }
        }
      }

      if(possiblePlaces > 1) {
        list.add(value);
      }
    }

    return list;
  }

  // returns all numbers used in the current quadrant
  List<int> getQuadrantNumbers(List<int> puzzle, int x, int y) {
    List<int> list = [];
    int offsetX = ((x - x%3)/3).round();
    int offsetY = ((y - y%3)/3).round();

    for(int yy=0;yy<3;yy++) {
      for(int xx=0;xx<3;xx++) {
        list.add(puzzle[xx + offsetX * 3 + (yy + offsetY * 3)*9]);
      }
    }

    return list;
  }

  // returns all numbers used on the current column
  List<int> getVerticalNumbers(List<int> puzzle, int x) {
    List<int> list = [];

    for(int y=0;y<9;y++) {
      list.add(puzzle[x + y*9]);
    }

    return list;
  }

  // returns all numbers used on the current row
  List<int> getHorizontalNumbers(List<int> puzzle, int y) {
    List<int> list = [];

    for(int x=0;x<9;x++) {
      list.add(puzzle[x + y*9]);
    }

    return list;
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
  /*
      1 7 . | . . 8 | . . 2    1 7 9 | 5 4 8 | 3 6 2
      2 5 . | 7 . . | . . 8    2 5 4 | 7 3 6 | 1 9 8
      . . . | 9 1 . | . . 4    3 6 8 | 9 1 2 | 5 7 4
      - - - - - - - - - - -    - - - - - - - - - - -
      4 8 3 | 6 . 5 | . 2 1    4 8 3 | 6 9 5 | 7 2 1
      . 2 5 | 4 . 1 | . . .    9 2 5 | 4 7 1 | 6 8 3
      . 1 . | . . 3 | . 5 .    7 1 6 | 8 2 3 | 4 5 9
      - - - - - - - - - - -    - - - - - - - - - - -
      . . 1 | . 5 4 | 8 3 .    6 9 1 | 2 5 4 | 8 3 7
      . . . | . 8 . | 9 . .    5 4 2 | 3 8 7 | 9 1 6
      . 3 7 | 1 6 . | . . .    8 3 7 | 1 6 9 | 2 4 5
  */

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