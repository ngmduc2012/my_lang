// GENERATED CODE - CAREFULLY MODIFY BY HAND

import 'package:my_lang/my_lang.dart';

/* **************************************************************************
RUN on project terminal
dart pub global activate my_lang 

my_lang
my_lang -i en.json -o interpreter.dart -c OurLang
************************************************************************** */
extension OurLang on MyLang {
  String get youhavepushedthebuttonthismanytimes =>
      translate('youhavepushedthebuttonthismanytimes');
  String get increment => translate('increment');
  String get language => translate('language');
  String get welcomeBack => translate('welcomeBack');
  String? welcomeBackNameApp(
    String nameUser,
    String nameApp,
  ) =>
      translate('welcomeBackNameApp', params: {
        'nameUser': nameUser,
        'nameApp': nameApp,
      });
}
