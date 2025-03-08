# my\_lang

## Introduction

`my_lang` is a library that provides flexible and easy-to-use localization support for Flutter applications.

## Features

- Multi-language support using JSON files.
- Easy to integrate and use.
- Dynamic language switching in the app.
- Automatically reads JSON files and generates Dart files without manually entering each key.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
my_lang: ^latest_version

flutter:
  assets:
    - assets/i18n/
```

## JSON Language File Structure

Create JSON files inside the `assets/i18n/` directory:

**en.json**

```json
{
  "welcomeBack": "Welcome Back",
  "welcomeBackNameApp": "Welcome @nameUser Back @nameApp"
}
```

**vi.json**

```json
{
  "welcomeBack": "Chào mừng trở lại",
  "welcomeBackNameApp": "Chào mừng @nameUser trở lại @nameApp"
}
```

## Initializing the Library

```dart
import 'package:my_lang/my_lang.dart';
import 'package:flutter/widgets.dart';

MyLang myLang = MyLang();

const listLocale = [
  Locale('en'),
  Locale('vi'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myLang.setUp(listLocale: listLocale);
  runApp(MyApp());
}
```

## Creating the `interpreter.dart` File

Create the `interpreter.dart` file containing the `OurLang` class:

```dart
import 'package:my_lang/my_lang.dart';

class OurLang extends MyLang {
  static String get welcomeBack => MyLang.translate('welcomeBack');
  static String? welcomeBackNameApp(String nameUser, String nameApp) =>
      MyLang.translate('welcomeBackNameApp', params: {
        'nameUser': nameUser,
        'nameApp': nameApp,
      });
}
```

## Usage

```dart
print(OurLang.welcomeBack); // "Welcome Back" or "Chào mừng trở lại"
print(OurLang.welcomeBackNameApp("John", "MyApp"));
```

## Changing Language in the App

```dart
myLang.loadFileJson(locale: myLang.locale.languageCode == 'en'
? const Locale("vi")
    : const Locale("en"));
```

## Generating `OurLang` Automatically

Run the following command to automatically generate `interpreter.dart`:

```sh
dart pub global activate my_lang
dart run my_lang -i assets/i18n/en.json -o lib/interpreter.dart
```

> 💡 **Tip:** Quickly copy a file path using these shortcuts:
> - **MacBook**: `Command (⌘) + Option (⌥) + C`
> - **Windows**: `Ctrl + Shift + C`


## Contribution

If you have any suggestions or find any issues, feel free to open an issue or submit a pull request on [GitHub](https://github.com/your-repo/my_lang).

## Developer Team:

Any comments please contact us [ThaoDoan](https://github.com/mia140602) and [DucNguyen](https://github.com/ngmduc2012).

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-orange.png)](https://buymeacoffee.com/ducmng12g)

[![Support Me on Ko-fi](https://storage.ko-fi.com/cdn/kofi6.png?v=6)](https://ko-fi.com/I2I81AEJG8)









