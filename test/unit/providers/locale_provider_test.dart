import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock para SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late ProviderContainer container;

  setUp(() {
    // Configurar os mocks
    mockSharedPreferences = MockSharedPreferences();
    
    // Configurar o comportamento padrão
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
    when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
    
    // Injetar o mock no LocaleProvider
    LocaleNotifier.prefs = mockSharedPreferences;
    
    // Criar o container do Riverpod
    container = ProviderContainer();
  });

  tearDown(() {
    // Limpar o container após cada teste
    container.dispose();
  });

  group('LocaleProvider Tests', () {
    test('Estado inicial deve ser português quando não há preferência salva', () {
      // Configurar o mock para retornar null (nenhuma preferência salva)
      when(() => mockSharedPreferences.getString('locale')).thenReturn(null);
      
      // Obter o estado inicial
      final locale = container.read(localeProvider);
      
      // Verificar se o estado inicial é português
      expect(locale.languageCode, 'pt');
    });

    test('Estado inicial deve carregar a preferência salva', () {
      // Configurar o mock para retornar uma preferência salva
      when(() => mockSharedPreferences.getString('locale')).thenReturn('en');
      
      // Recriar o notifier para que ele carregue a preferência
      final notifier = LocaleNotifier();
      
      // Verificar se o estado inicial é o idioma salvo
      expect(notifier.state.languageCode, 'en');
    });

    test('setLocale deve atualizar o estado e salvar a preferência', () async {
      // Obter o notifier
      final notifier = container.read(localeProvider.notifier);
      
      // Chamar o método setLocale
      await notifier.setLocale(const Locale('en'));
      
      // Verificar se o estado foi atualizado
      expect(container.read(localeProvider).languageCode, 'en');
      
      // Verificar se a preferência foi salva
      verify(() => mockSharedPreferences.setString('locale', 'en')).called(1);
    });

    test('getCurrentLanguageName deve retornar o nome do idioma atual', () {
      // Configurar o estado inicial
      final notifier = container.read(localeProvider.notifier);
      
      // Verificar o nome do idioma para português
      expect(notifier.getCurrentLanguageName(), 'Português');
      
      // Atualizar o idioma para inglês
      notifier.setLocale(const Locale('en'));
      
      // Verificar o nome do idioma para inglês
      expect(notifier.getCurrentLanguageName(), 'English');
    });

    test('getSupportedLanguages deve retornar a lista de idiomas suportados', () {
      // Obter o notifier
      final notifier = container.read(localeProvider.notifier);
      
      // Obter a lista de idiomas suportados
      final languages = notifier.getSupportedLanguages();
      
      // Verificar se a lista contém português e inglês
      expect(languages.length, 2);
      expect(languages[0]['code'], 'pt');
      expect(languages[0]['name'], 'Português');
      expect(languages[1]['code'], 'en');
      expect(languages[1]['name'], 'English');
    });
  });
}
