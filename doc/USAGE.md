# MyLang Usage (Short)

## 1) Add dependency and assets

```yaml
dependencies:
  my_lang: ^1.0.0+1

flutter:
  assets:
    - assets/i18n/
```

## 2) Create JSON files

`assets/i18n/en.json`

```json
{
  "welcomeBack": "Welcome Back",
  "welcomeBackNameApp": "Welcome @nameUser Back @nameApp"
}
```

`assets/i18n/vi.json`

```json
{
  "welcomeBack": "Chao mung tro lai",
  "welcomeBackNameApp": "Chao mung @nameUser tro lai @nameApp"
}
```

## 3) Initialize in `main`

```dart
import 'package:flutter/material.dart';
import 'package:my_lang/my_lang.dart';

final myLang = MyLang();
const listLocale = [Locale('en'), Locale('vi')];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myLang.setUp(listLocale: listLocale);
  runApp(const MyApp());
}
```

## 4) Use translations

```dart
final title = myLang.translate('welcomeBack');
final welcome = myLang.translate('welcomeBackNameApp', params: {
  'nameUser': 'Wong',
  'nameApp': 'Lang',
});
```

## 5) Switch language

```dart
await myLang.loadFileJson(locale: const Locale('vi'));
```

## 6) Optional: generate typed helpers

```sh
dart pub global activate my_lang
my_lang -i assets/i18n/en.json -o lib/languages/interpreter.dart -c OurLang
```

```dart
import 'package:my_lang/my_lang.dart';
import 'languages/interpreter.dart';

myLang.welcomeBack;
myLang.welcomeBackNameApp('Wong', 'Lang');
```
