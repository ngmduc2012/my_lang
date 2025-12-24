import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_lang/my_lang.dart';
import 'package:my_lang/src/shared_preference.dart';

const Map<String, String> _assetData = {
  'assets/i18n/en.json':
      '{"hello":"Hello","withParams":"Hello @name","multi":"Hi @first @last"}',
  'assets/i18n/en-.json': '{"hello":"HelloDash"}',
  'assets/i18n/en-US.json': '{"hello":"Howdy"}',
  'assets/i18n/vi.json': '{"hello":"Xin chao","empty":"--"}',
  'custom_assets/vi.json': '{"custom":"CustomVi"}',
};

Future<ByteData?> _assetHandler(ByteData? message) async {
  if (message == null) {
    throw FlutterError('Missing asset message.');
  }
  final key = utf8.decode(
    message.buffer.asUint8List(
      message.offsetInBytes,
      message.lengthInBytes,
    ),
  );
  var content = _assetData[key];
  if (content == null && key.startsWith('packages/my_lang/')) {
    content = _assetData[key.replaceFirst('packages/my_lang/', '')];
  }
  if (content == null && key.startsWith('/')) {
    content = _assetData[key.substring(1)];
  }
  if (content == null) {
    throw FlutterError('Missing asset for key: $key');
  }
  final bytes = utf8.encode(content);
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}

void _registerMockAssets() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', _assetHandler);
}

class _FakePrefs extends MyPrefs {
  final Map<String, Object?> store = {};

  @override
  Future<void> setUp() async {}

  @override
  Future<bool> write(String key, dynamic value) async {
    store[key] = value;
    return true;
  }

  @override
  Future<T?> read<T>(String key) async {
    final value = store[key];
    if (value is T) {
      return value;
    }
    return null;
  }
}

class _TestMyLang extends MyLang {
  bool reassembleRequested = false;

  @override
  Future<bool> loadFileJson({Locale? locale, bool isReloadApp = true}) async {
    if (isReloadApp) {
      reassembleRequested = true;
    }
    return super.loadFileJson(locale: locale, isReloadApp: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _registerMockAssets();
    SharedPreferences.setMockInitialValues({});
  });

  group('MyPrefs', () {
    test('setUp initializes SharedPreferences instance', () async {
      final prefs = MyPrefs();
      await prefs.setUp();
      expect(prefs.prefs, isNotNull);
    });

    test('tryBool passes through successful futures', () async {
      final prefs = MyPrefs();
      final result = await prefs.tryBool(Future<bool>.value(true));
      expect(result, isTrue);
    });

    test('tryBool surfaces async errors', () async {
      final prefs = MyPrefs();
      await expectLater(
        prefs.tryBool(Future<bool>.error(Exception('fail'))),
        throwsA(isA<Exception>()),
      );
    });

    test('write stores primitive types', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      expect(await prefs.write('stringKey', 'value'), isTrue);
      expect(prefs.prefs!.getString('stringKey'), equals('value'));

      expect(await prefs.write('intKey', 42), isTrue);
      expect(prefs.prefs!.getInt('intKey'), equals(42));

      expect(await prefs.write('boolKey', true), isTrue);
      expect(prefs.prefs!.getBool('boolKey'), isTrue);

      expect(await prefs.write('doubleKey', 3.14), isTrue);
      expect(prefs.prefs!.getDouble('doubleKey'), equals(3.14));
    });

    test('write stores Map<String, dynamic> as JSON string', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final map = <String, dynamic>{'a': 1, 'b': 'two'};
      expect(await prefs.write('mapKey', map), isTrue);
      expect(prefs.prefs!.getString('mapKey'), equals(jsonEncode(map)));
    });

    test('write stores DateTime as string', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final now = DateTime(2024, 1, 2, 3, 4, 5);
      expect(await prefs.write('dateKey', now), isTrue);
      expect(prefs.prefs!.getString('dateKey'), equals(now.toString()));
    });

    test('write handles List<String> input', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final list = <String>['a', 'b'];
      final shouldStore = list.runtimeType == List<String>;
      final result = await prefs.write('listKey', list);
      expect(result, equals(shouldStore));
      if (shouldStore) {
        expect(prefs.prefs!.getStringList('listKey'), equals(list));
      } else {
        expect(prefs.prefs!.getStringList('listKey'), isNull);
      }
    });

    test('write returns false for unsupported types', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      expect(await prefs.write('durationKey', const Duration(seconds: 1)),
          isFalse);
      expect(prefs.prefs!.get('durationKey'), isNull);
    });

    test('write returns false for null values', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      expect(await prefs.write('nullKey', null), isFalse);
      expect(prefs.prefs!.get('nullKey'), isNull);
    });

    test('write returns false for non-Map<String, dynamic> maps', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final map = <String, Object>{'k': 'v'};
      expect(await prefs.write('mapKey', map), isFalse);
      expect(prefs.prefs!.get('mapKey'), isNull);
    });

    test('read returns null when prefs is not initialized', () async {
      final prefs = MyPrefs();
      expect(await prefs.read<String>('missingKey'), isNull);
    });

    test('read retrieves primitive types', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      await prefs.write('stringKey', 'value');
      await prefs.write('intKey', 7);
      await prefs.write('boolKey', false);
      await prefs.write('doubleKey', 2.5);

      expect(await prefs.read<String>('stringKey'), equals('value'));
      expect(await prefs.read<int>('intKey'), equals(7));
      expect(await prefs.read<bool>('boolKey'), isFalse);
      expect(await prefs.read<double>('doubleKey'), equals(2.5));
    });

    test('read retrieves List<String> values', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      await prefs.prefs!.setStringList('listKey', <String>['x', 'y']);
      expect(await prefs.read<List<String>>('listKey'), equals(<String>['x', 'y']));
    });

    test('read returns null for missing List<String> key', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      expect(await prefs.read<List<String>>('missingList'), isNull);
    });

    test('read returns null for String when stored type differs', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      await prefs.write('stringKey', 123);
      expect(await prefs.read<String>('stringKey'), isNull);
    });

    test('read retrieves Map<String, dynamic> values', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final map = <String, dynamic>{'k': 'v'};
      await prefs.prefs!.setString('mapKey', jsonEncode(map));
      expect(await prefs.read<Map<String, dynamic>>('mapKey'), equals(map));
      expect(await prefs.read<Map<String, dynamic>>('missingMap'), isNull);
    });

    test('read returns null for invalid Map<String, dynamic> JSON', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      await prefs.prefs!.setString('mapKey', '{invalid_json');
      expect(await prefs.read<Map<String, dynamic>>('mapKey'), isNull);
    });

    test('read retrieves DateTime values', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final timestamp = DateTime(2023, 5, 6, 7, 8, 9);
      await prefs.prefs!.setString('dateKey', timestamp.toString());
      expect(await prefs.read<DateTime>('dateKey'), equals(timestamp));
      expect(await prefs.read<DateTime>('missingDate'), isNull);
    });

    test('write then read DateTime round-trips', () async {
      final prefs = MyPrefs();
      await prefs.setUp();

      final timestamp = DateTime(2022, 2, 3, 4, 5, 6);
      expect(await prefs.write('dateKey', timestamp), isTrue);
      expect(await prefs.read<DateTime>('dateKey'), equals(timestamp));
    });

    test('read returns null for unsupported types', () async {
      final prefs = MyPrefs();
      await prefs.setUp();
      expect(await prefs.read<Duration>('durationKey'), isNull);
    });
  });

  group('MyLang', () {
    test('setUp loads stored locale and custom path/key', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs()..store['customKey'] = 'vi';
      myLang.myStorage = fakePrefs;

      await myLang.setUp(
        listLocale: const [Locale('en'), Locale('vi')],
        path: 'custom_assets/',
        keySaveLocale: 'customKey',
      );

      expect(myLang.keySaveLocale, equals('customKey'));
      expect(myLang.pathInAssets, equals('custom_assets/'));
      expect(myLang.locale, equals(const Locale('vi')));
      expect(myLang.localizedStrings!['custom'], equals('CustomVi'));
      expect(myLang.reassembleRequested, isTrue);
    });

    test('setUp uses default path and key when not provided', () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs();

      await myLang.setUp(listLocale: const [Locale('en')]);

      expect(myLang.keySaveLocale, equals(constSaveLocale));
      expect(myLang.pathInAssets, equals('assets/i18n/'));
      expect(myLang.locale, equals(const Locale('en')));
      expect(myLang.localizedStrings!['hello'], equals('Hello'));
      expect(myLang.reassembleRequested, isTrue);
    });

    test('loadLocal returns first locale when nothing is stored', () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs();
      myLang.listLocale = const [Locale('en'), Locale('vi')];
      await myLang.myStorage.setUp();

      final locale = await myLang.loadLocal();
      expect(locale, equals(const Locale('en')));
    });

    test('loadLocal returns stored locale when available', () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs()..store[constSaveLocale] = 'vi';
      myLang.listLocale = const [Locale('en'), Locale('vi')];
      await myLang.myStorage.setUp();

      final locale = await myLang.loadLocal();
      expect(locale, equals(const Locale('vi')));
    });

    test('loadLocal falls back to current locale when stored value is unsupported',
        () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs()..store[constSaveLocale] = 'fr';
      myLang.listLocale = const [Locale('en'), Locale('vi')];
      myLang.locale = const Locale('en');
      await myLang.myStorage.setUp();

      final locale = await myLang.loadLocal();
      expect(locale, equals(const Locale('en')));
    });

    test('loadLocal throws when stored value is unsupported and locale is unset',
        () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs()..store[constSaveLocale] = 'fr';
      myLang.listLocale = const [Locale('en'), Locale('vi')];
      await myLang.myStorage.setUp();

      await expectLater(
        myLang.loadLocal(),
        throwsA(isA<Error>()),
      );
    });

    test('saveLocal ignores null locale', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs();
      myLang.myStorage = fakePrefs;
      await myLang.myStorage.setUp();

      myLang.saveLocal(locale: null);
      expect(fakePrefs.store[myLang.keySaveLocale], isNull);
    });

    test('saveLocal persists locale when provided', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs();
      myLang.myStorage = fakePrefs;
      await myLang.myStorage.setUp();

      myLang.saveLocal(locale: const Locale('vi'));
      expect(fakePrefs.store[myLang.keySaveLocale], equals('vi'));
    });

    test('loadFileJson loads language without country code', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs();
      myLang.myStorage = fakePrefs;
      await myLang.myStorage.setUp();

      final ok = await myLang.loadFileJson(
        locale: const Locale('en'),
        isReloadApp: false,
      );

      expect(ok, isTrue);
      expect(myLang.locale, equals(const Locale('en')));
      expect(Intl.defaultLocale, equals('en'));
      expect(myLang.localizedStrings!['hello'], equals('Hello'));
      expect(fakePrefs.store[myLang.keySaveLocale], equals('en'));
      expect(myLang.reassembleRequested, isFalse);
    });

    test('loadFileJson loads language with country code', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs();
      myLang.myStorage = fakePrefs;
      await myLang.myStorage.setUp();

      final ok = await myLang.loadFileJson(
        locale: const Locale('en', 'US'),
        isReloadApp: true,
      );

      expect(ok, isTrue);
      expect(myLang.locale, equals(const Locale('en', 'US')));
      expect(Intl.defaultLocale, equals('en'));
      expect(myLang.localizedStrings!['hello'], equals('Howdy'));
      expect(fakePrefs.store[myLang.keySaveLocale], equals('en_US'));
      expect(myLang.reassembleRequested, isTrue);
    });

    test('loadFileJson loads empty countryCode as dashed file name', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs();
      myLang.myStorage = fakePrefs;
      await myLang.myStorage.setUp();

      final ok = await myLang.loadFileJson(
        locale: const Locale('en', ''),
        isReloadApp: false,
      );

      expect(ok, isTrue);
      expect(myLang.locale, equals(const Locale('en', '')));
      expect(Intl.defaultLocale, equals('en'));
      expect(myLang.localizedStrings!['hello'], equals('HelloDash'));
      expect(fakePrefs.store[myLang.keySaveLocale], equals('en'));
      expect(myLang.reassembleRequested, isFalse);
    });

    test('loadFileJson keeps stored locale when none is provided', () async {
      final myLang = _TestMyLang();
      final fakePrefs = _FakePrefs()..store[constSaveLocale] = 'en';
      myLang.myStorage = fakePrefs;
      myLang.keySaveLocale = constSaveLocale;
      myLang.locale = const Locale('vi');
      await myLang.myStorage.setUp();

      final ok = await myLang.loadFileJson(isReloadApp: false);

      expect(ok, isTrue);
      expect(Intl.defaultLocale, equals('vi'));
      expect(myLang.localizedStrings!['hello'], equals('Xin chao'));
      expect(fakePrefs.store[constSaveLocale], equals('en'));
      expect(myLang.reassembleRequested, isFalse);
    });

    test('loadFileJson toggles reassemble flag based on isReloadApp', () async {
      final myLang = _TestMyLang();
      myLang.myStorage = _FakePrefs();
      await myLang.myStorage.setUp();

      await myLang.loadFileJson(locale: const Locale('en'), isReloadApp: false);
      expect(myLang.reassembleRequested, isFalse);

      await myLang.loadFileJson(locale: const Locale('en'), isReloadApp: true);
      expect(myLang.reassembleRequested, isTrue);
    });

    test('translate returns key when no localization map exists', () async {
      final myLang = MyLang();
      expect(myLang.translate('missing'), equals('missing'));
    });

    test('translate returns key for missing or disabled entries', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'empty': '--'};

      expect(myLang.translate('unknown'), equals('unknown'));
      expect(myLang.translate('empty'), equals('empty'));
    });

    test('translate replaces placeholders when params are provided', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {
        'withParams': 'Hello @name',
        'multi': 'Hi @first @last',
      };

      expect(
        myLang.translate('withParams', params: {'name': 'Alice'}),
        equals('Hello Alice'),
      );
      expect(
        myLang.translate('multi', params: {'first': 'A', 'last': 'B'}),
        equals('Hi A B'),
      );
    });

    test('translate ignores params not present in the template', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'hello': 'Hello'};

      expect(
        myLang.translate('hello', params: {'name': 'Alice'}),
        equals('Hello'),
      );
    });

    test('translate replaces params with underscore keys', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'welcome': 'Hello @user_name'};

      expect(
        myLang.translate('welcome', params: {'user_name': 'Alice'}),
        equals('Hello Alice'),
      );
    });

    test('translate returns raw value when params are empty', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'hello': 'Hello'};
      expect(myLang.translate('hello'), equals('Hello'));
    });

    test('translate returns empty string when value is empty', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'emptyValue': ''};
      expect(myLang.translate('emptyValue'), equals(''));
    });

    test('translate replaces repeated placeholders', () async {
      final myLang = MyLang();
      myLang.localizedStrings = {'repeat': '@name @name'};
      expect(
        myLang.translate('repeat', params: {'name': 'Alice'}),
        equals('Alice Alice'),
      );
    });
  });

  group('MyLocaleHelper', () {
    test('isEnglish matches language code', () {
      expect(const Locale('en').isEnglish, isTrue);
      expect(const Locale('en', 'US').isEnglish, isTrue);
      expect(const Locale('vi').isEnglish, isFalse);
    });

    test('isVietnamese matches language code', () {
      expect(const Locale('vi').isVietnamese, isTrue);
      expect(const Locale('en').isVietnamese, isFalse);
    });

    test('isKorean matches language code', () {
      expect(const Locale('ko').isKorean, isTrue);
      expect(const Locale('en').isKorean, isFalse);
    });

    test('isJapanese matches language code', () {
      expect(const Locale('ja').isJapanese, isTrue);
      expect(const Locale('en').isJapanese, isFalse);
    });
  });
}
