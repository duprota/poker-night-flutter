import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final supportedLanguages = localeNotifier.getSupportedLanguages();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBarWidget(
        title: l10n.languageSettingTitle,
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = supportedLanguages[index];
          final isSelected = language['code'] == currentLocale.languageCode;
          
          return Card(
            color: const Color(0xFF222222),
            margin: const EdgeInsets.only(bottom: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: isSelected 
                ? const BorderSide(color: Color(0xFF8B5CF6), width: 2.0)
                : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: 8.0
              ),
              title: Text(
                language['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                ),
              ),
              trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF8B5CF6),
                  )
                : null,
              onTap: () {
                localeNotifier.setLocale(language['locale']);
              },
            ),
          );
        },
      ),
    );
  }
}
