# Operations (Short)

## First run (repo)

```sh
make init
make test
```

## Push code

```sh
make push
```

## Generate language helpers (optional)

```sh
dart pub global activate my_lang
my_lang -i assets/i18n/en.json -o lib/languages/interpreter.dart -c OurLang
```

## Publish to pub.dev

1) Update version in `pubspec.yaml`.
2) Update `CHANGELOG.md`.
3) Commit code changes.
4) Validate: `dart pub publish --dry-run`
5) Publish: `dart pub publish`

If this is your first publish, run `dart pub login` first.
