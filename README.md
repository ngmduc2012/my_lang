

[![GitHub](https://img.shields.io/badge/Nguyen_Duc-GitHub-black?logo=github)](https://github.com/ngmduc2012)
_[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy_Me_A_Coffee-blue?logo=buymeacoffee)](https://www.buymeacoffee.com/ducmng12g)_
_[![PayPal](https://img.shields.io/badge/Donate-PayPal-blue?logo=paypal)](https://paypal.me/ngmduc)_
_[![Sponsor](https://img.shields.io/badge/Sponsor-Become_A_Sponsor-blue?logo=githubsponsors)](https://github.com/sponsors/ngmduc2012)_
_[![Support Me on Ko-fi](https://img.shields.io/badge/Donate-Ko_fi-red?logo=ko-fi)](https://ko-fi.com/I2I81AEJG8)_  

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
```

```sh
my_lang 
```

```sh
my_lang -i assets/i18n/en.json -o lib/interpreter.dart -c YourLang 
```

> 💡 **Tip:** Quickly copy a file path using these shortcuts on Android Studio:
> - **MacBook**: `Command (⌘) + Option (⌥) + C`
> - **Windows**: `Ctrl + Shift + C`


## Contribution

If you have any suggestions or find any issues, feel free to open an issue or submit a pull request on [GitHub](https://github.com/ngmduc2012/my_lang).
If you want to know what i do in package, checking my document here https://wong-coupon.gitbook.io/flutter/ui/multi-language

## Developer Team:

Any comments please contact us [ThaoDoan](https://github.com/mia140602) and [DucNguyen](https://github.com/ngmduc2012).








