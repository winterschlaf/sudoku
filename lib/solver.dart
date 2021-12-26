import 'package:flutter/services.dart';

class Solver {
  static const int emptyTile = 0;
  List<int> puzzleOriginal = [];
  List<int> puzzleCurrent = [];
  Stopwatch stopwatch = Stopwatch();

  Solver() {
    clear();
  }

  Future<bool> solve() async {
    stopwatch.start();
    fillInObvious();
    stopwatch.stop();
    return isSolved(puzzleCurrent) && isValidSolution(puzzleCurrent);
  }

  // tries to fill in all obvious numbers
  // iterate until no new number was set
  void fillInObvious() {
    bool changed = true;

    while (changed) {
      changed = false;

      for (int y = 0; y < 9; y++) {
        for (int x = 0; x < 9; x++) {
          //skip any number already filled in, zero means it is not filled!
          if (puzzleCurrent[x + y * 9] == emptyTile) {
            List<int> potentialNumbers =
                getPotentialNumbersForTile(puzzleCurrent, x, y);
            //we only want none ambiguous numbers here
            potentialNumbers.removeWhere((element) =>
                getAmbiguousQuadrantNumbers(
                        puzzleCurrent, potentialNumbers, x, y)
                    .contains(element));

            // if only one number is left, use it
            if (potentialNumbers.length == 1) {
              puzzleCurrent[x + y * 9] = potentialNumbers[0];
              changed = true;
            }
          }
        }
      }
    }
  }

  List<int> getPotentialNumbersForTile(List<int> puzzle, int x, int y) {
    List<int> potentialNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    //remove all numbers that are already used horizontally
    potentialNumbers.removeWhere(
        (element) => getHorizontalNumbers(puzzle, y).contains(element));
    //remove all numbers that are already used vertically
    potentialNumbers.removeWhere(
        (element) => getVerticalNumbers(puzzle, x).contains(element));
    //remove all numbers that are already used in the current quadrant
    potentialNumbers.removeWhere(
        (element) => getQuadrantNumbers(puzzle, x, y).contains(element));
    return potentialNumbers;
  }

  bool isSolved(List<int> puzzle) {
    bool solved = true;

    for (int i = 0; i < 9 * 9 && solved; i++) {
      solved = (puzzle[i] != emptyTile);
    }

    return solved;
  }

  bool isValidSolution(List<int> puzzle) {
    bool valid = true;
    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    //check quadrant
    for (int y = 0; y < 9 && valid; y += 3) {
      for (int x = 0; x < 9 && valid; x += 3) {
        List<int> tmp = [];
        tmp.addAll(numbers);
        tmp.removeWhere(
            (element) => getQuadrantNumbers(puzzle, x, y).contains(element));
        valid = tmp.isEmpty;
      }
    }

    //check vertical numbers
    for (int x = 0; x < 9 && valid; x++) {
      List<int> tmp = [];
      tmp.addAll(numbers);
      tmp.removeWhere(
          (element) => getVerticalNumbers(puzzle, x).contains(element));
      valid = tmp.isEmpty;
    }

    //check horizontal numbers
    for (int y = 0; y < 9 && valid; y++) {
      List<int> tmp = getHorizontalNumbers(puzzle, y);
      tmp.removeWhere(
          (element) => getHorizontalNumbers(puzzle, y).contains(element));
      valid = tmp.isEmpty;
    }

    return valid;
  }

  // returns a list of numbers that can be used on multiple tiles
  List<int> getAmbiguousQuadrantNumbers(
      List<int> puzzle, List<int> potentialNumbers, int x, int y) {
    List<int> list = [];
    int offsetX = ((x - x % 3) / 3).round();
    int offsetY = ((y - y % 3) / 3).round();

    for (int e = potentialNumbers.length; e > 0; e--) {
      int value = potentialNumbers[e - 1];
      int possiblePlaces = 0;

      for (int yy = 0; yy < 3; yy++) {
        for (int xx = 0; xx < 3; xx++) {
          if (puzzle[xx + offsetX * 3 + (yy + offsetY * 3) * 9] == emptyTile) {
            possiblePlaces += (!getHorizontalNumbers(puzzle, yy + offsetY * 3)
                        .contains(value) &&
                    !getVerticalNumbers(puzzle, xx + offsetX * 3)
                        .contains(value))
                ? 1
                : 0;
          }
        }
      }

      if (possiblePlaces > 1) {
        list.add(value);
      }
    }

    return list;
  }

  // returns all numbers used in the current quadrant
  List<int> getQuadrantNumbers(List<int> puzzle, int x, int y) {
    List<int> list = [];
    int offsetX = ((x - x % 3) / 3).round();
    int offsetY = ((y - y % 3) / 3).round();

    for (int yy = 0; yy < 3; yy++) {
      for (int xx = 0; xx < 3; xx++) {
        int value = puzzle[xx + offsetX * 3 + (yy + offsetY * 3) * 9];
        list.add(value);
      }
    }

    return list;
  }

  // returns all numbers used on the current column
  List<int> getVerticalNumbers(List<int> puzzle, int x) {
    List<int> list = [];

    for (int y = 0; y < 9; y++) {
      int value = puzzle[x + y * 9];
      list.add(value);
    }

    return list;
  }

  // returns all numbers used on the current row
  List<int> getHorizontalNumbers(List<int> puzzle, int y) {
    List<int> list = [];

    for (int x = 0; x < 9; x++) {
      int value = puzzle[x + y * 9];
      list.add(value);
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
        .replaceAllMapped(
            RegExp(r'[\r\n]', caseSensitive: false), (match) => '')
        .replaceAllMapped(RegExp(r'[^1-9]', caseSensitive: false),
            (match) => emptyTile.toString());

    if (puzzle.length != 9 * 9) {
      throw Exception(
          "puzzle has to contain exactly ${9 * 9} characters, found ${puzzle.length} characters");
    }

    clear();

    for (int i = 0; i < 9 * 9; i++) {
      puzzleCurrent[i] = int.parse(puzzle[i]);
      puzzleOriginal[i] = int.parse(puzzle[i]);
    }
  }

  void clear() {
    stopwatch.stop();
    puzzleCurrent = getEmptyPuzzle();
    puzzleOriginal = getEmptyPuzzle();
  }

  List<int> getEmptyPuzzle() {
    List<int> list = [];

    for (int i = 0; i < 9 * 9; i++) {
      list.add(emptyTile);
    }

    return list;
  }

  String getStatistics() {
    return 'time: ${stopwatch.elapsedMilliseconds}ms';
  }
}
