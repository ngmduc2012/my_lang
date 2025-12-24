import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _resolveAssetsDir() {
  const candidates = [
    'assets/i18n',
    'example/assets/i18n',
  ];
  for (final candidate in candidates) {
    final dir = Directory(candidate);
    if (dir.existsSync()) {
      return dir.path;
    }
  }
  throw StateError(
    'Unable to locate assets/i18n directory. Checked: ${candidates.join(", ")}',
  );
}

Map<String, Map<String, String>> _loadLocaleMaps(String assetsDir) {
  final dir = Directory(assetsDir);
  final files = dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    throw StateError('No .json files found in $assetsDir');
  }

  final result = <String, Map<String, String>>{};
  for (final file in files) {
    final locale = file.uri.pathSegments.last.replaceAll('.json', '');
    final content = file.readAsStringSync();
    final decoded = json.decode(content);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Expected a JSON object in ${file.path}');
    }
    final map = <String, String>{};
    decoded.forEach((key, value) {
      map[key.toString()] = value.toString();
    });
    result[locale] = map;
  }
  return result;
}

Set<String> _extractPlaceholders(String value) {
  final matches = RegExp(r'@([A-Za-z0-9_]+)').allMatches(value);
  return matches.map((match) => match.group(1)!).toSet();
}

void main() {
  group('Asset/data validation', () {
    late String assetsDir;
    late Map<String, Map<String, String>> localeMaps;

    setUpAll(() {
      assetsDir = _resolveAssetsDir();
      localeMaps = _loadLocaleMaps(assetsDir);
    });

    test('contains expected locales', () {
      expect(localeMaps.keys, containsAll(<String>['en', 'vi']));
    });

    test('all locale files are valid maps of non-empty strings', () {
      localeMaps.forEach((locale, map) {
        expect(map, isNotEmpty, reason: '$locale has no translations');
        map.forEach((key, value) {
          expect(key.trim(), isNotEmpty, reason: '$locale has empty key');
          expect(value.trim(), isNotEmpty,
              reason: '$locale/$key has empty value');
          expect(value.trim(), isNot('--'),
              reason: '$locale/$key uses placeholder "--"');
        });
      });
    });

    test('all locales share the same keys', () {
      final baseLocale =
          localeMaps.containsKey('en') ? 'en' : localeMaps.keys.first;
      final baseKeys = localeMaps[baseLocale]!.keys.toSet();
      localeMaps.forEach((locale, map) {
        expect(map.keys.toSet(), equals(baseKeys),
            reason: '$locale keys differ from $baseLocale');
      });
    });

    test('placeholders match across locales', () {
      final baseLocale =
          localeMaps.containsKey('en') ? 'en' : localeMaps.keys.first;
      final baseMap = localeMaps[baseLocale]!;

      localeMaps.forEach((locale, map) {
        if (locale == baseLocale) return;
        baseMap.forEach((key, baseValue) {
          final basePlaceholders = _extractPlaceholders(baseValue);
          final localePlaceholders = _extractPlaceholders(map[key] ?? '');
          expect(localePlaceholders, equals(basePlaceholders),
              reason: '$locale/$key placeholder mismatch');
        });
      });
    });
  });
}
