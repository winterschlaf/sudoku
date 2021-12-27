import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/sudoku/output.dart';
import 'package:sudoku/sudoku/puzzle.dart';

// read more here:
// https://docs.flutter.dev/cookbook/testing/unit/introduction
// https://pub.dev/packages/test
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('iterate assets', () async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final sudoku = json
        .decode(manifestJson)
        .keys
        .where(
            (String key) =>
        key.startsWith('assets/sudoku')
            && key.endsWith('.txt')
    );

    for(String s in sudoku) {
      String fileName = s.replaceAll('\\', '/');
      fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
      var matches = RegExp(r'(\d+)x(\d+)_(\d+)x(\d+).+').allMatches(fileName);

      if(matches.isEmpty) {
        print('$fileName does not follow the pattern ^\\d+x\\d+_\\d+x\\d+');
        continue;
      }

      print(matches.length);
      print(
          '${matches.elementAt(0).group(0)}'
          '${matches.elementAt(0).group(1)}'
              '${matches.elementAt(0).group(2)}'
              '${matches.elementAt(0).group(3)}'
      );
      Puzzle puzzle = Puzzle(9, 9, 3, 3);
      puzzle
          .loadFromAssets(s)
          .then((value) => print('loaded $s: $value'))
          .whenComplete(() =>
            puzzle
                .solve()
                .then((value) => 'solved: $value')
                .whenComplete(() => print(
                  '${puzzle.stopwatch.elapsedMilliseconds}ms'
                  '\n${getVisualRepresentationOfPuzzleSideBySide(puzzle)}'
                )));
    }
  });
}