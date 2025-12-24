import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lang/my_lang.dart';

import 'package:example/main.dart' as app;

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

class _TestMyLang extends MyLang {
  int loadCalls = 0;
  Locale? lastLocale;

  @override
  Future<bool> loadFileJson({Locale? locale, bool isReloadApp = true}) async {
    loadCalls += 1;
    this.locale = locale ?? this.locale;
    lastLocale = this.locale;
    localizedStrings =
        this.locale.languageCode == 'vi' ? _viStrings : _enStrings;
    return true;
  }
}

void main() {
  late _TestMyLang testLang;

  setUp(() {
    testLang = _TestMyLang()
      ..locale = const Locale('en')
      ..localizedStrings = _enStrings;
    app.myLang = testLang;
  });

  testWidgets('renders English UI and increments counter', (tester) async {
    await tester.pumpWidget(const app.MyApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, equals('Welcome Back'));
    expect(find.text('Welcome Wong Back Lang'), findsOneWidget);
    expect(
      find.text('You have pushed the button this many times:'),
      findsOneWidget,
    );
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('language toggle switches between English and Vietnamese',
      (tester) async {
    await tester.pumpWidget(const app.MyApp());

    await tester.tap(find.text('Language'));
    await tester.pump();

    expect(testLang.loadCalls, equals(1));
    expect(testLang.lastLocale, equals(const Locale('vi')));
    await tester.pumpWidget(const app.MyApp());

    expect(find.text('Chào mừng Wong trở lại Lang'), findsOneWidget);
    expect(
      find.text('Bạn đã nhấn nút nhiều lần như sau:'),
      findsOneWidget,
    );
    expect(find.text('Ngôn ngữ'), findsOneWidget);

    await tester.tap(find.text('Ngôn ngữ'));
    await tester.pump();

    expect(testLang.loadCalls, equals(2));
    expect(testLang.lastLocale, equals(const Locale('en')));
    await tester.pumpWidget(const app.MyApp());

    expect(find.text('Welcome Wong Back Lang'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });
}
