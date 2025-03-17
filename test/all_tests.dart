import 'package:flutter_test/flutter_test.dart';

// Testes unitários
import 'unit/providers/auth_provider_test.dart' as auth_provider_test;
import 'unit/providers/feature_toggle_provider_test.dart' as feature_toggle_provider_test;

// Testes de widget
import 'widget/screens/language_settings_screen_test.dart' as language_settings_screen_test;

// Testes de integração
import 'integration/navigation_test.dart' as navigation_test;

void main() {
  group('Testes Unitários', () {
    auth_provider_test.main();
    feature_toggle_provider_test.main();
  });

  group('Testes de Widget', () {
    language_settings_screen_test.main();
  });

  group('Testes de Integração', () {
    navigation_test.main();
  });
}
