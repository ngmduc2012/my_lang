import 'dart:convert';
import 'dart:io';

String inputFilePath = '';
String outputFilePath = '';
String className = 'OurLang'; // Giá trị mặc định

/// STEP 1 | input file .json - output file interpreter.dart
// WINDOW PATH use r"PATH" instead for "PATH"
// Learn more https://dart.dev/language/built-in-types#:~:text=You%20can%20create%20a,gets%20special%20treatment.%27%3B
void main(List<String> arguments) async {
  // Parse command line arguments
  for (var i = 0; i < arguments.length; i++) {
    if (arguments[i] == '-i' && i + 1 < arguments.length) {
      inputFilePath = arguments[i + 1];
    } else if (arguments[i] == '-o' && i + 1 < arguments.length) {
      outputFilePath = arguments[i + 1];
    } else if (arguments[i] == '-c' && i + 1 < arguments.length) {
      className = arguments[i + 1];
    }
  }

  while (inputFilePath.isEmpty) {
    print('? Enter the input json file path (e.g: pathTo/en.json:');
    String? input = stdin.readLineSync();
    if (input != null && input.isNotEmpty) {
      inputFilePath = input.trim();
    }
  }

  while (outputFilePath.isEmpty) {
    print('Enter the output file path (e.g: pathTo/interpreter.dart:');
    String? output = stdin.readLineSync();
    if (output != null && output.isNotEmpty) {
      outputFilePath = output.trim();
    }
  }

  print('Enter the class name (default: OurLang):');
  String? inputClassName = stdin.readLineSync();
  if (inputClassName != null && inputClassName.isNotEmpty) {
    className = inputClassName.trim();
  }

  final file = File(inputFilePath);
  final contents = await file.readAsString();
  final Map<String, dynamic> jsonData =
      jsonDecode(contents) as Map<String, dynamic>;

  jsonData.forEach((key, value) {
    print("  static String get $key => MyInterpreter.translate('$key');");
  });

  await writeToFile(outputFilePath, jsonData, className);
}

Future<void> writeToFile(
    String filePath, Map<String, dynamic> data, String className) async {
  final file = File(filePath);
  final sink = file.openWrite();

  // Ghi nội dung vào tệp Dart
  sink.writeln("// GENERATED CODE - CAREFULLY MODIFY BY HAND\n");
  sink.writeln("import 'package:my_lang/my_lang.dart';\n");
  sink.writeln(
      "/* **************************************************************************");
  sink.writeln("RUN on project terminal");
  sink.writeln("dart pub global activate my_lang \n");
  sink.writeln("my_lang");
  sink.writeln("my_lang -i en.json -o interpreter.dart -c $className");
  sink.writeln(
      "************************************************************************** */");
  sink.writeln('class $className extends MyLang {\n');
  data.forEach((key, value) {
    final List<String> split = value.toString().split(" ");
    if (split.myItemContain("@")) {
      final List<String> splitParam =
          split.where((e) => e.contains("@")).toList();
      String a = "";
      String b = "";
      for (final e in splitParam) {
        a += "String ${e.substring(1, e.length)},";
        b += "'${e.substring(1, e.length)}': ${e.substring(1, e.length)},";
      }
      sink.writeln(
          "  static String? $key($a) => MyLang.translate('$key', params: {$b});");
    } else {
      sink.writeln("  static String get $key => MyLang.translate('$key');");
    }
  });
  sink.writeln('\n}');
  await sink.close();
}

extension MyListStringHelper on List<String> {
  /// Item list string contain context
  bool myItemContain(String context) {
    for (final element in this) {
      if (element.contains(context)) return true;
    }
    return false;
  }

  /// context contain item in list
  bool myContextContainItem(String context) {
    for (final element in this) {
      if (context.contains(element)) return true;
    }
    return false;
  }
}
