import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'shared_preference.dart';

/// The key used to save and retrieve the locale from persistent storage.
const String constSaveLocale = 'constSaveLocaleInPackageCureStorage';

/// A class for managing localization and translations in a Flutter application.
///
/// This class handles loading locale data from JSON files, saving and retrieving
/// the current locale, and translating keys to localized strings.
class MyLang {
  /// The current locale of the application.
  late Locale locale;

  /// The list of supported locales.
  late List<Locale> listLocale;

  /// The path to the directory containing the localization JSON files in the assets.
  String pathInAssets = "assets/i18n/";

  /// A map containing the localized strings, where the key is the translation key
  /// and the value is the localized string.
  static Map<String, String>? localizedStrings;

  /// An instance of `MyPrefs` for managing persistent storage.
  MyPrefs myStorage = MyPrefs();

  /// Sets up the localization system.
  ///
  /// This method must be called before using any other methods in this class.
  /// It initializes the list of supported locales, sets up the persistent storage,
  /// loads the current locale, and loads the localization data from the JSON file.
  ///
  /// Args:
  ///   listLocale: The list of supported locales.
  ///   path: An optional path to the directory containing the localization JSON files.
  Future<void> setUp({required List<Locale> listLocale, String? path}) async {
    this.listLocale = listLocale;
    await myStorage.setUp();
    locale = await loadLocal();
    if (path != null) pathInAssets = path;
    await loadFileJson();
  }

  /// Retrieves the stored locale from persistent storage.
  ///
  /// This method reads the saved locale from persistent storage and returns it.
  /// If no locale is saved, it returns the first locale in the list of supported locales.
  /// If the saved locale is not in the list of supported locales, it returns the current locale.
  ///
  /// Returns:
  ///   The stored locale, or the first locale in the list of supported locales if no locale is stored.
  Future<Locale> loadLocal() async {
    final getLocale = await myStorage.read<String>(constSaveLocale);
    if (getLocale != null) {
      try {
        return listLocale
            .firstWhere((element) => element.toString() == getLocale);
      } catch (e) {
        return locale;
      }
    } else {
      return listLocale.first;
    }
  }

  /// Saves the specified locale to persistent storage.
  ///
  /// Args:
  ///   locale: The locale to save. If null, nothing is saved.
  void saveLocal({Locale? locale}) {
    if (locale == null) return;
    myStorage.write(constSaveLocale, locale.toString());
  }

  /// Loads the localization data from the JSON file for the specified locale.
  ///
  /// This method loads the JSON file corresponding to the specified locale,
  /// decodes it, and stores the localized strings in the `localizedStrings` map.
  /// It also sets the default locale for the `Intl` package and saves the locale to memory.
  ///
  /// Args:
  ///   locale: The locale for which to load the JSON file. If null, the current locale is used.
  ///
  /// Returns:
  ///   `true` if the JSON file was successfully loaded and parsed, `false` otherwise.
  Future<bool> loadFileJson({Locale? locale}) async {
    this.locale = locale ?? this.locale;
    Intl.defaultLocale = this.locale.languageCode;
    saveLocal(locale: locale);
    final String jsonString = await rootBundle.loadString(
        '$pathInAssets${this.locale.languageCode}${this.locale.countryCode != null ? ("-${this.locale.countryCode}") : ""}.json');
    final Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    await WidgetsFlutterBinding.ensureInitialized().performReassemble();
    return true;
  }

  /// Translates a key to a localized string.
  ///
  /// This method looks up the translation for the specified key in the
  /// `localizedStrings` map. If the key is not found or the value is "--",
  /// it returns the key itself. If the translation contains placeholders
  /// (e.g., `@name`), it replaces them with the corresponding values from the
  /// `params` map.
  ///
  /// Args:
  ///   key: The translation key.
  ///   params: An optional map of parameters to replace placeholders in the translation.
  ///
  /// Returns:
  ///   The localized string, or the key itself if no translation is found.
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

/// An extension on the `Locale` class to provide helper methods for checking
/// the language of a locale.
extension MyLocaleHelper on Locale {
  /// Checks if the locale is English.
  bool get isEnglish => Locale(languageCode) == const Locale("en");

  /// Checks if the locale is Vietnamese.
  bool get isVietnamese => Locale(languageCode) == const Locale("vi");

  /// Checks if the locale is Korean.
  bool get isKorean => Locale(languageCode) == const Locale("ko");

  /// Checks if the locale is Japanese.
  bool get isJapanese => Locale(languageCode) == const Locale("ja");
}
