import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar o idioma do aplicativo
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier para gerenciar o estado do idioma
class LocaleNotifier extends StateNotifier<Locale> {
  // Inicializa com português como idioma padrão
  LocaleNotifier() : super(const Locale('pt')) {
    _loadSavedLocale();
  }
  
  /// Carregar o idioma salvo nas preferências
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString('locale');
      
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 1) {
          state = Locale(parts[0]);
        } else if (parts.length > 1) {
          state = Locale(parts[0], parts[1]);
        }
      }
    } catch (e) {
      print('Erro ao carregar idioma: $e');
    }
  }
  
  /// Alterar o idioma do aplicativo
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (locale.countryCode != null) {
        await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
      } else {
        await prefs.setString('locale', locale.languageCode);
      }
      
      state = locale;
    } catch (e) {
      print('Erro ao salvar idioma: $e');
    }
  }
  
  /// Obter o nome do idioma atual
  String getCurrentLanguageName() {
    switch (state.languageCode) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      default:
        return 'Português';
    }
  }
  
  /// Obter a lista de idiomas suportados
  List<Map<String, dynamic>> getSupportedLanguages() {
    return [
      {'code': 'pt', 'name': 'Português', 'locale': const Locale('pt')},
      {'code': 'en', 'name': 'English', 'locale': const Locale('en')},
      // Adicione mais idiomas aqui no futuro
    ];
  }
}
