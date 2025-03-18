import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

void main() {
  runApp(const LocalizationDemoApp());
}

class LocalizationDemoApp extends StatelessWidget {
  const LocalizationDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localization Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('pt'), // Portuguese
      ],
      home: const LocalizationDemoScreen(),
    );
  }
}

class LocalizationDemoScreen extends StatefulWidget {
  const LocalizationDemoScreen({Key? key}) : super(key: key);

  @override
  State<LocalizationDemoScreen> createState() => _LocalizationDemoScreenState();
}

class _LocalizationDemoScreenState extends State<LocalizationDemoScreen> {
  Locale _currentLocale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = SafeL10n(l10n);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Localization Demo - ${_currentLocale.languageCode.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() {
                _currentLocale = _currentLocale.languageCode == 'en' 
                    ? const Locale('pt') 
                    : const Locale('en');
              });
            },
            tooltip: 'Change language',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExampleCard(
              'Regular Localizations (from AppLocalizations)',
              [
                _buildRow('l10n.appTitle', l10n.appTitle),
                _buildRow('l10n.welcomeMessage', l10n.welcomeMessage),
              ],
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              'SafeL10n with Fallback',
              [
                _buildRow('safeL10n.appTitle', safeL10n.get('appTitle', 'Fallback App Title')),
                _buildRow('safeL10n.welcomeMessage', safeL10n.get('welcomeMessage', 'Fallback Welcome')),
                _buildRow('safeL10n.nonExistentString', safeL10n.get('nonExistentString', 'This is a fallback for missing string')),
              ],
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              'SafeL10n Method Getters',
              [
                _buildRow('safeL10n.settingsTitle', safeL10n.settingsTitle),
                _buildRow('safeL10n.profileTitle', safeL10n.profileTitle),
                _buildRow('safeL10n.createGroup', safeL10n.createGroup),
              ],
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              'Parameterized Messages',
              [
                _buildRow('safeL10n.welcomeUser("John")', safeL10n.welcomeUser('John')),
                _buildRow('safeL10n.deleteGroupConfirmation("Poker Night")', safeL10n.deleteGroupConfirmation('Poker Night')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String title, List<Widget> rows) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
