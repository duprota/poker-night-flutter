import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider Tests', () {
    test('Supported themes should include dark, light, purple and blue', () {
      // Criando uma instância direta do ThemeNotifier para teste
      final themeNotifier = ThemeNotifier();
      final supportedThemes = themeNotifier.getSupportedThemes();
      
      expect(supportedThemes.length, equals(4)); // dark, light, purple, blue
      
      // Verificar se cada tema está incluído
      expect(
        supportedThemes.any((theme) => theme['code'] == AppTheme.dark),
        isTrue,
      );
      expect(
        supportedThemes.any((theme) => theme['code'] == AppTheme.light),
        isTrue,
      );
      expect(
        supportedThemes.any((theme) => theme['code'] == AppTheme.purple),
        isTrue,
      );
      expect(
        supportedThemes.any((theme) => theme['code'] == AppTheme.blue),
        isTrue,
      );
    });
    
    test('Theme names should be correctly mapped', () {
      final themeNotifier = ThemeNotifier();
      
      // Verificar o nome do tema inicial
      expect(themeNotifier.getCurrentThemeName(), equals('Escuro'));
      
      // Mudar o tema e verificar o novo nome
      themeNotifier.debugSetThemeWithoutSaving(AppTheme.light);
      expect(themeNotifier.getCurrentThemeName(), equals('Claro'));
      
      // Mudar para outro tema e verificar o nome
      themeNotifier.debugSetThemeWithoutSaving(AppTheme.purple);
      expect(themeNotifier.getCurrentThemeName(), equals('Roxo'));
      
      // Mudar para outro tema e verificar o nome
      themeNotifier.debugSetThemeWithoutSaving(AppTheme.blue);
      expect(themeNotifier.getCurrentThemeName(), equals('Azul'));
    });
    
    test('Theme data should change when theme is changed', () {
      final themeNotifier = ThemeNotifier();
      
      // Tema inicial deve ser dark
      expect(themeNotifier.currentTheme, equals(AppTheme.dark));
      expect(themeNotifier.state.brightness, equals(Brightness.dark));
      
      // Mudar para tema light
      themeNotifier.debugSetThemeWithoutSaving(AppTheme.light);
      
      // Tema deve ser atualizado
      expect(themeNotifier.currentTheme, equals(AppTheme.light));
      expect(themeNotifier.state.brightness, equals(Brightness.light));
      
      // Mudar para tema purple
      themeNotifier.debugSetThemeWithoutSaving(AppTheme.purple);
      
      // Tema deve ser atualizado novamente
      expect(themeNotifier.currentTheme, equals(AppTheme.purple));
      expect(themeNotifier.state.brightness, equals(Brightness.dark));
    });
  });
}
