import 'package:flutter_test/flutter_test.dart';

// Testes unitários
import 'unit/providers/auth_provider_test.dart' as auth_provider_test;
import 'unit/providers/feature_toggle_provider_test.dart' as feature_toggle_provider_test;
import 'unit/providers/locale_provider_test.dart' as locale_provider_test;
import 'unit/providers/game_provider_test.dart' as game_provider_test;
import 'unit/providers/player_provider_test.dart' as player_provider_test;
import 'unit/utils/subscription_utils_test.dart' as subscription_utils_test;
import 'unit/utils/feature_access_test.dart' as feature_access_test;

// Testes de widget
import 'widget/screens/language_settings_screen_test.dart' as language_settings_screen_test;
import 'widget/screens/settings_screen_test.dart' as settings_screen_test;
import 'widget/widgets/localized_text_test.dart' as localized_text_test;

// Testes de integração
import 'integration/navigation_test.dart' as navigation_test;

void main() {
  group('Testes Unitários', () {
    auth_provider_test.main();
    feature_toggle_provider_test.main();
    locale_provider_test.main();
    game_provider_test.main();
    player_provider_test.main();
    subscription_utils_test.main();
    feature_access_test.main();
  });

  group('Testes de Widget', () {
    language_settings_screen_test.main();
    settings_screen_test.main();
    localized_text_test.main();
  });

  group('Testes de Integração', () {
    navigation_test.main();
  });
}
