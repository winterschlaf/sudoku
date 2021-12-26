import 'dart:convert';
import 'package:flutter/services.dart';

// read more here:
// https://docs.flutter.dev/cookbook/testing/unit/introduction
// https://pub.dev/packages/test
Future<void> main() async {
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  final puzzle = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/sudoku'));

  for(String p in puzzle) {
    print(p);
  }
}