// represents a sudoku puzzle
// x and y represent the overall size of the puzzle, e.g. 9x9 or 4x4
// quadrantX and quadrantY represent the sub squares, e.g. in a 6x6 puzzle
// quadrantX is 3 and quadrantY is 2 or vise versa but they cannot be the same
import 'package:flutter/services.dart';

class Puzzle {
  List<int> original = [];
  List<int> puzzle = [];
  int noValue = 0;
  int x;
  int y;
  int quadrantX;
  int quadrantY;
  Stopwatch stopwatch = Stopwatch();

  Puzzle(
      this.x,
      this.y,
      this.quadrantX,
      this.quadrantY
      );

  Future<bool> solve() async {
    stopwatch.start();
    solveNaively();
    solveBruteForce();
    stopwatch.stop();
    return isValid();
  }

  //go over every field and try all entries
  //stop when you found a valid solution
  bool solveBruteForce() {
    //if it solved at any point, abort
    if(isValid()) {
      return true;
    }

    for(int j=0;j<y;j++) {
      for (int i = 0; i < x; i++) {
        if (puzzle[i + j * x] == noValue) {
          //its enough to check a subset
          for(int value in getAllValidValuesForCurrentPosition(i, j)) {
            puzzle[i + j * x] = value;

            //try this number and go to next tile
            if(solveBruteForce()) {
              return true;
            }

            //that number dint work out go back
            puzzle[i + j * x] = noValue;
          }

          //do not forget to send back that it didn't work
          return false;
        }
      }
    }

    //at this point everything should be solved, so send back true
    return true;
  }

  //tries to solve the puzzle with a naive approach
  //basically iterates over each tile and checks if there is a unique number which fits
  void solveNaively() {
    if(isValid()) {
      return;
    }

    bool changed = true;

    while(changed) {
      changed = false;

      for(int j=0;j<y;j++) {
        for(int i=0;i<x;i++) {
          if(puzzle[i + j * x] == noValue) {
            List<int> values = getAllValidValuesForCurrentPosition(i, j);
            values.removeWhere((element) =>
                getAllAmbiguousValuesForCurrentPosition(i, j).contains(
                    element));

            if (values.length == 1) {
              puzzle[i + j * x] = values[0];
              changed = true;
            }
          }
        }
      }
    }
  }

  // loads puzzle from assets via its path
  // e.g. assets/sudoku/4x4_2x2_002.txt
  Future<bool> loadFromAssets(String path) async {
    return loadFromString(await rootBundle.loadString(path));
  }

  bool loadFromString(String strValue) {
    if (strValue.trim().isEmpty) {
      throw Exception('string cannot be empty');
    }

    puzzle.clear();
    strValue = strValue
        .replaceAllMapped(
            RegExp(r'[\r\n]', caseSensitive: false),
            (match) => '')
        .replaceAllMapped(
            RegExp(r'[^1-9]', caseSensitive: false),
            (match) => noValue.toString());

    for (String value in strValue.split('')) {
      puzzle.add(int.parse(value));
      original.add(int.parse(value));
    }

    return true;
  }

  //checks if the puzzle is solved and valid
  bool isValid() {
    bool valid = true;

    for(int j=0;j<y && valid;j++) {
      for(int i=0;i<x && valid;i++) {
        valid = isColumnValid(i) && isRowValid(j) && isQuadrantValid(i, j);
      }
    }

    return valid;
  }

  // return all numbers of a specified row
  // does not include the noValue
  List<int> getRowValues(int y) {
    List<int> values = [];

    for(int i=0;i<x;i++) {
      int value = puzzle[i + y * x];

      if(value != noValue) {
        values.add(value);
      }
    }

    return values;
  }

  //check if a specific row is valid
  bool isRowValid(int y) {
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => getRowValues(y).contains(element));

    return validValues.isEmpty;
  }

  //checks if the entries in a row are valid to the point they were filled in
  bool isRowValidSoFar(int y) {
    List<int> values = getRowValues(y);
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => values.contains(element));

    return validValues.isEmpty || getAllValidValues().length == (validValues.length + values.length);
  }

  // return all numbers of a specified column
  // does not include the noValue
  List<int> getColumnValues(int x) {
    List<int> values = [];

    for(int i=0;i<y;i++) {
      int value = puzzle[x + i * this.x];

      if(value != noValue) {
        values.add(value);
      }
    }

    return values;
  }

  //check if a specific column is valid
  bool isColumnValid(int x) {
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => getColumnValues(x).contains(element));

    return validValues.isEmpty;
  }

  //checks if the entries in a column are valid to the point they were filled in
  bool isColumnValidSoFar(int y) {
    List<int> values = getColumnValues(y);
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => values.contains(element));

    return validValues.isEmpty || getAllValidValues().length == (validValues.length + values.length);
  }

  // return all numbers of a quadrant determined by the specified column/row
  // does not include the noValue
  List<int> getQuadrantValues(int x, int y) {
    List<int> values = [];

    int offsetX = ((x - x%quadrantX)/quadrantX).round() * quadrantX;
    int offsetY = ((y - y%quadrantY)/quadrantY).round() * quadrantY;

    for(int i=0;i<quadrantY;i++) {
      for(int j=0;j<quadrantX;j++) {
        int value = puzzle[j + offsetX + (i + offsetY) * this.x];

        if(value != noValue) {
          values.add(value);
        }
      }
    }

    return values;
  }

  //check if a specific quadrant is valid
  bool isQuadrantValid(int x, int y) {
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => getQuadrantValues(x, y).contains(element));

    return validValues.isEmpty;
  }

  //checks if the entries in a quadrant are valid to the point they were filled in
  bool isQuadrantValidSoFar(int x, int y) {
    List<int> values = getQuadrantValues(x, y);
    List<int> validValues = getAllValidValues();
    validValues.removeWhere((element) => values.contains(element));
    return validValues.isEmpty || getAllValidValues().length == (validValues.length + values.length);
  }

  List<int> getAllValidValues() {
    List<int> values = [];

    for(int i=0;i<x;i++) {
      values.add(i+1);
    }

    return values;
  }

  //returns a list of zero or more values which can be used on the current tile
  //the returned values should have no conflict within the same row, column and quadrant
  List<int> getAllValidValuesForCurrentPosition(int x, int y) {
    List<int> values = getAllValidValues();
    values.removeWhere((element) => getColumnValues(x).contains(element));
    values.removeWhere((element) => getRowValues(y).contains(element));
    values.removeWhere((element) => getQuadrantValues(x, y).contains(element));

    return values;
  }

  // gets all numbers which can be used in multiple places of the same quadrant
  List<int> getAllAmbiguousValuesForCurrentPosition(int x, int y) {
    List<int> values = [];

    //first get all valid values for the whole quadrant
    int offsetX = ((x - x%quadrantX)/quadrantX).round() * quadrantX;
    int offsetY = ((y - y%quadrantY)/quadrantY).round() * quadrantY;

    for(int i=0;i<quadrantY;i++) {
      for(int j=0;j<quadrantX;j++) {
        int value = puzzle[j + offsetX + (i + offsetY) * this.x];

        if(value == noValue) {
          values.addAll(getAllValidValuesForCurrentPosition(j + offsetX, i + offsetY));
        }
      }
    }

    //remove any numbers which are unique
    for(int i in getAllValidValues()) {
      if(values.where((e) => e == i).length < 2) {
        values.removeWhere((element) => element == i);
      }
    }

    return values;
  }
}
