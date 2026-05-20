# Finance Tracker Flutter

A Flutter port of the finance tracker app from the `mobile` Expo project.

## Included

- Profile and first-source setup
- Source-aware total balance
- Income, expense, borrow, and lend transactions
- Monthly analytics by category
- Weekly or monthly category budgets
- Smart Cart with item quantities, discounts, coupons, checkout budget status, and cart history
- Local finance chat for balance, expense, income, budget, and cart questions
- Settings for profile, theme, sources, and local data reset
- SharedPreferences local persistence using the same `@ehk_*` storage key style as the Expo app

## Run Locally

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze
flutter test
```

## GitHub Notes

Commit the Flutter source, `pubspec.yaml`, `pubspec.lock`, platform folders, and this README. Do not commit `.dart_tool/`, build output, `android/local.properties`, or generated Flutter environment files.
