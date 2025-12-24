import 'package:flutter_test/flutter_test.dart';
import 'package:my_lang/my_lang.dart';

import 'package:example/languages/interpreter.dart';

const Map<String, String> _enStrings = {
  'youhavepushedthebuttonthismanytimes':
      'You have pushed the button this many times:',
  'increment': 'Increment',
  'language': 'Language',
  'welcomeBack': 'Welcome Back',
  'welcomeBackNameApp': 'Welcome @nameUser Back @nameApp',
};

const Map<String, String> _viStrings = {
  'youhavepushedthebuttonthismanytimes':
      'Bạn đã nhấn nút nhiều lần như sau:',
  'increment': 'Tăng',
  'language': 'Ngôn ngữ',
  'welcomeBack': 'Chào mừng trở lại',
  'welcomeBackNameApp': 'Chào mừng @nameUser trở lại @nameApp',
};

void main() {
  group('OurLang extension', () {
    test('returns English strings', () {
      final myLang = MyLang()..localizedStrings = _enStrings;

      expect(
        myLang.youhavepushedthebuttonthismanytimes,
        equals('You have pushed the button this many times:'),
      );
      expect(myLang.increment, equals('Increment'));
      expect(myLang.language, equals('Language'));
      expect(myLang.welcomeBack, equals('Welcome Back'));
    });

    test('returns Vietnamese strings', () {
      final myLang = MyLang()..localizedStrings = _viStrings;

      expect(
        myLang.youhavepushedthebuttonthismanytimes,
        equals('Bạn đã nhấn nút nhiều lần như sau:'),
      );
      expect(myLang.increment, equals('Tăng'));
      expect(myLang.language, equals('Ngôn ngữ'));
      expect(myLang.welcomeBack, equals('Chào mừng trở lại'));
    });

    test('welcomeBackNameApp replaces parameters in English', () {
      final myLang = MyLang()..localizedStrings = _enStrings;

      expect(
        myLang.welcomeBackNameApp('Wong', 'Lang'),
        equals('Welcome Wong Back Lang'),
      );
    });

    test('welcomeBackNameApp replaces parameters in Vietnamese', () {
      final myLang = MyLang()..localizedStrings = _viStrings;

      expect(
        myLang.welcomeBackNameApp('Wong', 'Lang'),
        equals('Chào mừng Wong trở lại Lang'),
      );
    });
  });
}
