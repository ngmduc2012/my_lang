import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for managing data persistence using `SharedPreferences`.
///
/// This class provides methods to write and read various data types to and from
/// persistent storage. It simplifies the use of `SharedPreferences` by handling
/// type checking and error handling.
///
/// Example usage:
///
///
class MyPrefs {
/*
    Learn more: https://pub.dev/packages/shared_preferences
    How to use?
        Step 1: Define
          MyPrefs myPrefs = MyPrefs();
        Step 2: Setup on init
          myPrefs.setUp();
        Step 3: E.g use
          myPrefs.write(constSaveLocale, locale.toString());
*/

  /// The `SharedPreferences` instance used for data persistence.
  SharedPreferences? prefs;

  /// Initializes the `SharedPreferences` instance.
  ///
  /// This method must be called before any other methods in this class.
  /// It asynchronously retrieves the `SharedPreferences` instance.
  Future<void> setUp() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Attempts to execute a `Future<bool>` and returns its result.
  ///
  /// If an error occurs during the execution of the future, it prints the
  /// error to the debug console and returns `false`.
  ///
  /// Args:
  ///   future: The `Future<bool>` to execute.
  ///
  /// Returns:
  ///   The result of the future, or `false` if an error occurred.
  Future<bool> tryBool(Future<bool> future) async {
    try {
      return future;
    } catch (error) {
      debugPrint(error.toString());
      return Future(() => false);
    }
  }

  /// Writes a value to persistent storage with the specified key.
  ///
  /// This method supports various data types, including `String`, `int`,
  /// `bool`, `double`, `List<String>`, `Map<String, dynamic>`, and `DateTime`.
  /// It automatically detects the type of the value and uses the appropriate
  /// `SharedPreferences` method to store it.
  ///
  /// Args:
  ///   key: The key to associate with the value.
  ///   value: The value to store.
  ///
  /// Returns:
  ///   `true` if the value was successfully written, `false` otherwise.
  Future<bool> write(String key, dynamic value) async {
    final SharedPreferences prefs =
        this.prefs ??= await SharedPreferences.getInstance();
    if (value.runtimeType == String) {
      return tryBool(prefs.setString(key, value as String));
    } else if (value.runtimeType == int) {
      return tryBool(prefs.setInt(key, value as int));
    } else if (value.runtimeType == bool) {
      return tryBool(prefs.setBool(key, value as bool));
    } else if (value.runtimeType == double) {
      return tryBool(prefs.setDouble(key, value as double));
    } else if (value.runtimeType == List<String>) {
      return tryBool(prefs.setStringList(key, value as List<String>));
    } else if (value.runtimeType.toString() == "_Map<String, dynamic>") {
      return tryBool(prefs.setString(
          key, convert.jsonEncode(value as Map<String, dynamic>)));
    } else if (value.runtimeType == DateTime) {
      return tryBool(prefs.setString(key, value.toString()));
    } else {
      return Future(() => false);
    }
  }

  /// Reads a value from persistent storage with the specified key.
  ///
  /// This method supports various data types, including `String`, `int`,
  /// `bool`, `double`, `List<String>`, `Map<String, dynamic>`, and `DateTime`.
  /// It automatically detects the type of the value and uses the appropriate
  /// `SharedPreferences` method to read it.
  ///
  /// Note:
  ///   Ensure that `setUp()` has been called before calling this method.
  ///
  /// Args:
  ///   key: The key associated with the value to read.
  ///
  /// Returns:
  ///   The value associated with the key, or `null` if the key does not exist
  ///   or if an error occurred.
  Future<T?> read<T>(String key) async {
    try {
      final SharedPreferences prefs = this.prefs!;
      if (T == String) {
        return prefs.getString(key) as T;
      } else if (T == int) {
        return prefs.getInt(key) as T;
      } else if (T == bool) {
        return prefs.getBool(key) as T;
      } else if (T == double) {
        return prefs.getDouble(key) as T;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T;
      } else if (T == Map<String, dynamic>) {
        return prefs.getString(key) == null
            ? null
            : convert.jsonDecode(prefs.getString(key)!) as T;
      } else if (T == DateTime) {
        return prefs.getString(key) == null
            ? null
            : DateTime.parse(prefs.getString(key)!) as T;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
