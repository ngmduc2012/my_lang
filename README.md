<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

MyLang myLang = MyLang(); 

```dart
my_lang: ^lastest

flutter:
assets:
- assets/i18n/

en.json
{
"welcomeBack": "Welcome Back",
"welcomeBackNameApp": "Welcome @nameUser Back @nameApp"
}

vi.json
{
"welcomeBack": "Chào mừng trở lại",
"welcomeBackNameApp": "Chào mừng @nameUser trở lại @nameApp"
}

MyLang myLang = MyLang();

const listLocale = [
  Locale('en'),
  Locale('vi'),
];

WidgetsFlutterBinding.ensureInitialized();
await myLang.setUp(listLocale: listLocale);


import 'package:my_lang/my_lang.dart';

class OurLang extends MyLang {
  
static String get welcomeBack => MyLang.translate('welcomeBack');
static String? welcomeBackNameApp(String nameUser,String nameApp,) => MyLang.translate('welcomeBackNameApp', params: {'nameUser': nameUser,'nameApp': nameApp,});

}

OurLang.welcomeBack

dart pub global activate my_lang

/* **************************************************************************
RUN on project terminal
dart run my_lang
dart run my_lang -i en.json -o interpreter.dart
************************************************************************** */


myLang.loadFileJson(locale:  myLang.locale.isEnglish ? const Locale("vi") : const Locale("en"));

```

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
