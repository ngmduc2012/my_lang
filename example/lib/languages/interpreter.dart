// GENERATED CODE - CAREFULLY MODIFY BY HAND

import 'package:my_lang/my_lang.dart';

/* **************************************************************************
RUN on project terminal
dart run my_lang
dart run my_lang -i en.json -o interpreter.dart -c OurLang
************************************************************************** */
class OurLang extends MyLang {
  static String get youhavepushedthebuttonthismanytimes =>
      MyLang.translate('youhavepushedthebuttonthismanytimes');
  static String get increment => MyLang.translate('increment');
  static String get language => MyLang.translate('language');
  static String get welcomeBack => MyLang.translate('welcomeBack');
  static String? welcomeBackNameApp(
    String nameUser,
    String nameApp,
  ) =>
      MyLang.translate('welcomeBackNameApp', params: {
        'nameUser': nameUser,
        'nameApp': nameApp,
      });
}
