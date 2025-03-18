import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:poker_night/widgets/common/localized_text.dart';

void main() {
  runApp(const L10nDemoApp());
}

class L10nDemoApp extends StatelessWidget {
  const L10nDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L10n Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
      home: const L10nDemoScreen(),
    );
  }
}

class L10nDemoScreen extends StatefulWidget {
  const L10nDemoScreen({Key? key}) : super(key: key);

  @override
  State<L10nDemoScreen> createState() => _L10nDemoScreenState();
}

class _L10nDemoScreenState extends State<L10nDemoScreen> {
  Locale _currentLocale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _currentLocale = _currentLocale.languageCode == 'en' 
          ? const Locale('pt') 
          : const Locale('en');
    });
    
    // Force rebuild com o novo locale
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (context) => L10nDemoApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = SafeL10n(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text('L10n Demo - ${_currentLocale.languageCode.toUpperCase()}'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _toggleLocale,
            tooltip: 'Change language',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Strings with Translations',
              [
                _buildDemoItem('appTitle', LocalizedText(
                  textBuilder: (l10n) => l10n.appTitle,
                )),
                _buildDemoItem('welcomeMessage', LocalizedText(
                  textBuilder: (l10n) => l10n.welcomeMessage,
                )),
                _buildDemoItem('settingsTitle', LocalizedText(
                  textBuilder: (l10n) => l10n.settingsTitle,
                )),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Strings without Portuguese Translations (using fallback)',
              [
                _buildDemoItem('createGroup', LocalizedText(
                  textBuilder: (l10n) => l10n.createGroup,
                )),
                _buildDemoItem('logoutButton', LocalizedText(
                  textBuilder: (l10n) => l10n.logoutButton,
                )),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Parametrized Strings',
              [
                _buildDemoItem('welcomeUser("Eduardo")', LocalizedText(
                  textBuilder: (l10n) => safeL10n.welcomeUser('Eduardo'),
                )),
                _buildDemoItem('groupCreatedAt("Poker Friends", "Mar 18, 2025")', LocalizedText(
                  textBuilder: (l10n) => safeL10n.groupCreatedAt('Poker Friends', 'Mar 18, 2025'),
                )),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Direct SafeL10n Access (Always with fallback)',
              [
                _buildDemoItem('safeL10n.nonExistentString', Text(
                  'Result: "${safeL10n.get("nonExistentString", "This is a fallback")}"',
                )),
                _buildDemoItem('safeL10n.appTitle', Text(
                  'Result: "${safeL10n.appTitle}"',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDemoItem(String key, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}
