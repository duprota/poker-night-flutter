import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/providers/theme_provider.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = themeNotifier.currentTheme;
    final supportedThemes = themeNotifier.getSupportedThemes();

    return Scaffold(
      appBar: AppBarWidget(
        title: l10n.themeSettingTitle,
        showBackButton: true,
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
                  l10n.themeSelectionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.themeSelectionSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: supportedThemes.length,
              itemBuilder: (context, index) {
                final theme = supportedThemes[index];
                final isSelected = theme['code'] == currentTheme;
                
                // Get localized theme name
                String themeName = theme['name'];
                switch (theme['code']) {
                  case AppTheme.dark:
                    themeName = l10n.darkThemeOption;
                    break;
                  case AppTheme.light:
                    themeName = l10n.lightThemeOption;
                    break;
                  case AppTheme.purple:
                    themeName = l10n.purpleThemeOption;
                    break;
                  case AppTheme.blue:
                    themeName = l10n.blueThemeOption;
                    break;
                }
                
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
                      theme['icon'],
                      color: _getThemePreviewColor(theme['code']),
                    ),
                    title: Text(
                      themeName,
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
                      themeNotifier.setTheme(theme['code']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
}
