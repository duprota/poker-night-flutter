import 'package:flutter/material.dart';

void main() {
  runApp(const ThemeDemoApp());
}

enum AppTheme {
  dark,
  light,
  purple,
  blue,
}

class ThemeDemoApp extends StatefulWidget {
  const ThemeDemoApp({super.key});

  @override
  State<ThemeDemoApp> createState() => _ThemeDemoAppState();
}

class _ThemeDemoAppState extends State<ThemeDemoApp> {
  AppTheme _currentTheme = AppTheme.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Night Demo',
      theme: _getThemeData(_currentTheme),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Poker Night - Temas'),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o tema',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha o tema que melhor se adapta ao seu estilo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _getSupportedThemes().length,
                itemBuilder: (context, index) {
                  final theme = _getSupportedThemes()[index];
                  final isSelected = theme['code'] == _currentTheme;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: isSelected 
                        ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)
                        : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, 
                        vertical: 8.0
                      ),
                      leading: Icon(
                        theme['icon'] as IconData,
                        color: _getThemePreviewColor(theme['code'] as AppTheme),
                      ),
                      title: Text(
                        theme['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                      ),
                      trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                      onTap: () {
                        setState(() {
                          _currentTheme = theme['code'] as AppTheme;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSupportedThemes() {
    return [
      {
        'name': 'Escuro',
        'code': AppTheme.dark,
        'icon': Icons.dark_mode,
      },
      {
        'name': 'Claro',
        'code': AppTheme.light,
        'icon': Icons.light_mode,
      },
      {
        'name': 'Roxo',
        'code': AppTheme.purple,
        'icon': Icons.color_lens,
      },
      {
        'name': 'Azul',
        'code': AppTheme.blue,
        'icon': Icons.color_lens,
      },
    ];
  }

  // Retorna uma cor representativa para o preview do tema
  Color _getThemePreviewColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return const Color(0xFF1A1B1E);
      case AppTheme.light:
        return const Color(0xFFF8F9FA);
      case AppTheme.purple:
        return const Color(0xFF8B5CF6);
      case AppTheme.blue:
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF1A1B1E);
    }
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

  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF8B5CF6),
        secondary: const Color(0xFF6366F1),
        background: const Color(0xFF1A1B1E),
        surface: const Color(0xFF2A2B2F),
        error: Colors.red.shade800,
      ),
    );
  }

  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF8B5CF6),
        secondary: const Color(0xFF6366F1),
        background: const Color(0xFFF8F9FA),
        surface: Colors.white,
        error: Colors.red.shade600,
      ),
    );
  }

  ThemeData _getPurpleTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFAB8DF8),
        secondary: const Color(0xFF9E85F7),
        background: const Color(0xFF2D1B69),
        surface: const Color(0xFF3A2A75),
        error: Colors.red.shade800,
      ),
    );
  }

  ThemeData _getBlueTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF0EA5E9),
        secondary: const Color(0xFF38BDF8),
        background: const Color(0xFF0C4A6E),
        surface: const Color(0xFF075985),
        error: Colors.red.shade800,
      ),
    );
  }
}
