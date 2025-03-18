import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum para os temas disponíveis no aplicativo
enum AppTheme {
  dark,     // Tema escuro padrão
  light,    // Tema claro
  purple,   // Tema roxo (variação do escuro)
  blue,     // Tema azul (variação do escuro)
}

/// Provider para gerenciar o tema do aplicativo
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

/// Provider para acessar o modo de tema atual (enum)
final currentThemeModeProvider = Provider<AppTheme>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.currentTheme;
});

/// Notifier para gerenciar o estado do tema
class ThemeNotifier extends StateNotifier<ThemeData> {
  AppTheme _currentTheme = AppTheme.dark;
  
  // Getter para o tema atual
  AppTheme get currentTheme => _currentTheme;
  
  // Inicializa com o tema escuro como padrão
  ThemeNotifier() : super(_getDarkTheme()) {
    _loadSavedTheme();
  }
  
  /// Carregar o tema salvo nas preferências
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme');
      
      if (themeString != null) {
        final theme = AppTheme.values.firstWhere(
          (t) => t.toString() == themeString,
          orElse: () => AppTheme.dark,
        );
        setTheme(theme);
      }
    } catch (e) {
      print('Erro ao carregar tema: $e');
    }
  }
  
  /// Alterar o tema do aplicativo
  Future<void> setTheme(AppTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', theme.toString());
      
      _currentTheme = theme;
      
      switch (theme) {
        case AppTheme.dark:
          state = _getDarkTheme();
          break;
        case AppTheme.light:
          state = _getLightTheme();
          break;
        case AppTheme.purple:
          state = _getPurpleTheme();
          break;
        case AppTheme.blue:
          state = _getBlueTheme();
          break;
      }
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }
  
  /// Obter o nome do tema atual
  String getCurrentThemeName() {
    switch (_currentTheme) {
      case AppTheme.dark:
        return 'Escuro';
      case AppTheme.light:
        return 'Claro';
      case AppTheme.purple:
        return 'Roxo';
      case AppTheme.blue:
        return 'Azul';
      default:
        return 'Escuro';
    }
  }
  
  /// Obter a lista de temas suportados
  List<Map<String, dynamic>> getSupportedThemes() {
    return [
      {'code': AppTheme.dark, 'name': 'Escuro', 'icon': Icons.dark_mode},
      {'code': AppTheme.light, 'name': 'Claro', 'icon': Icons.light_mode},
      {'code': AppTheme.purple, 'name': 'Roxo', 'icon': Icons.color_lens},
      {'code': AppTheme.blue, 'name': 'Azul', 'icon': Icons.color_lens},
    ];
  }
  
  /// Tema escuro (padrão)
  static ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: Color(0xFF1A1B1E),
        surface: Color(0xFF222222),
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF0EA5E9),
        tertiary: Color(0xFFD946EF),
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1B1E),
      cardColor: const Color(0xFF222222),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1B1E),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  /// Tema claro
  static ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        background: Color(0xFFF8F9FA),
        surface: Color(0xFFFFFFFF),
        primary: Color(0xFF8B5CF6),
        secondary: Color(0xFF0EA5E9),
        tertiary: Color(0xFFD946EF),
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F9FA),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  /// Tema roxo (variação do escuro)
  static ThemeData _getPurpleTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: Color(0xFF2D1B69),
        surface: Color(0xFF372175),
        primary: Color(0xFFAA8DFF),
        secondary: Color(0xFF0EA5E9),
        tertiary: Color(0xFFD946EF),
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF2D1B69),
      cardColor: const Color(0xFF372175),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D1B69),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAA8DFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  /// Tema azul (variação do escuro)
  static ThemeData _getBlueTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        background: Color(0xFF0F2942),
        surface: Color(0xFF1A3A54),
        primary: Color(0xFF0EA5E9),
        secondary: Color(0xFF8B5CF6),
        tertiary: Color(0xFFD946EF),
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F2942),
      cardColor: const Color(0xFF1A3A54),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F2942),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  /// Método para testes - permite alterar o tema sem salvar nas preferências
  @visibleForTesting
  void debugSetThemeWithoutSaving(AppTheme theme) {
    _currentTheme = theme;
    state = _getThemeData(theme);
  }
  
  ThemeData _getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return _getDarkTheme();
      case AppTheme.light:
        return _getLightTheme();
      case AppTheme.purple:
        return _getPurpleTheme();
      case AppTheme.blue:
        return _getBlueTheme();
      default:
        return _getDarkTheme();
    }
  }
}
