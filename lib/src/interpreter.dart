import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'shared_preference.dart';

const String constSaveLocale = 'constSaveLocaleInPackageCureStorage';

class MyLang {

  late Locale locale;
  late List<Locale> listLocale;
  String pathInAssets = "assets/i18n/";
  static Map<String, String>? localizedStrings;

  MyPrefs myStorage = MyPrefs();

  Future<void> setUp({required List<Locale> listLocale, String? path}) async {
    this.listLocale = listLocale;
    await myStorage.setUp();
    locale = await loadLocal();
    if (path != null) pathInAssets = path;
    await loadFileJson();
  }

  /// Retrieve the stored locale from memory
  Future<Locale> loadLocal() async {
    final getLocale = await myStorage.read<String>(constSaveLocale);
    if (getLocale != null) {
      try {
        return listLocale.firstWhere((element) => element.toString() == getLocale);
      } catch (e) {
        return locale;
      }
    } else {
      return listLocale.first;
    }
  }

  /// Save the locale to memory
  void saveLocal({Locale? locale}) {
    if (locale == null) return;
    myStorage.write(constSaveLocale, locale.toString());
  }

  Future<bool> loadFileJson({Locale? locale}) async {
    this.locale = locale ?? this.locale;
    Intl.defaultLocale = this.locale.languageCode;
    saveLocal(locale: locale);
    final String jsonString = await rootBundle.loadString('$pathInAssets${this.locale.languageCode}${this.locale.countryCode != null ? ("-${this.locale.countryCode}") : ""}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    await WidgetsFlutterBinding.ensureInitialized().performReassemble();
    return true;
  }

  static String translate(String key, {Map<String, String> params = const {}}) {
    if (localizedStrings == null) return key;
    var trans = localizedStrings![key];
    if (trans == null || trans == "--") return key;
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        trans = trans!.replaceAll('@$key', value);
      });
    }
    return trans!;
  }
}

extension MyLocaleHelper on Locale {
  bool get isEnglish => Locale(languageCode) == const Locale("en");
  bool get isVietnamese => Locale(languageCode) == const Locale("vi");
  bool get isKorean => Locale(languageCode) == const Locale("ko");
  bool get isJapanese => Locale(languageCode) == const Locale("ja");
}
