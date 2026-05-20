import 'package:flutter_test/flutter_test.dart';
import 'package:transaction_app_flutter/models/app_state.dart';

void main() {
  test('new app state starts empty before persistence load', () {
    final appState = AppStateModel();

    expect(appState.sources, isEmpty);
    expect(appState.transactions, isEmpty);
    expect(appState.currentBalance(), 0);
  });
}
