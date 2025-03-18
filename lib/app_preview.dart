import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

void main() {
  runApp(const AppPreview());
}

class AppPreview extends StatelessWidget {
  const AppPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Night Preview',
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
      home: const AppPreviewScreen(),
    );
  }
}

class AppPreviewScreen extends StatefulWidget {
  const AppPreviewScreen({Key? key}) : super(key: key);

  @override
  State<AppPreviewScreen> createState() => _AppPreviewScreenState();
}

class _AppPreviewScreenState extends State<AppPreviewScreen> {
  Locale _currentLocale = const Locale('en');
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = SafeL10n(l10n);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Poker Night - ${_currentLocale.languageCode.toUpperCase()}'),
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
      body: _buildCurrentScreen(safeL10n),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: safeL10n.get('home', 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: safeL10n.get('groups', 'Groups'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: safeL10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: safeL10n.settingsTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(SafeL10n safeL10n) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen(safeL10n);
      case 1:
        return _buildGroupsScreen(safeL10n);
      case 2:
        return _buildNotificationsScreen(safeL10n);
      case 3:
        return _buildSettingsScreen(safeL10n);
      default:
        return _buildHomeScreen(safeL10n);
    }
  }

  Widget _buildHomeScreen(SafeL10n safeL10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_esports, size: 80),
          const SizedBox(height: 16),
          Text(
            safeL10n.get('welcomeMessage', 'Welcome to Poker Night'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            safeL10n.welcomeUser('Eduardo'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: Text(safeL10n.createGroup),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsScreen(SafeL10n safeL10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Text('P')),
          title: const Text('Poker Friends'),
          subtitle: Text(safeL10n.groupCreatedAt('Poker Friends')),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ),
        ListTile(
          leading: const CircleAvatar(child: Text('F')),
          title: const Text('Friday Night Poker'),
          subtitle: Text(safeL10n.groupCreatedAt('Friday Night Poker')),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: Text(safeL10n.createGroup),
        ),
      ],
    );
  }

  Widget _buildNotificationsScreen(SafeL10n safeL10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                safeL10n.notifications,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(safeL10n.markAllAsRead),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildNotificationItem(
                'Eduardo convidou você para um jogo',
                '2 horas atrás',
                safeL10n,
              ),
              _buildNotificationItem(
                'Novo jogo criado no grupo Poker Friends',
                '1 dia atrás',
                safeL10n,
              ),
              _buildNotificationItem(
                'Você foi adicionado ao grupo Friday Night Poker',
                '3 dias atrás',
                safeL10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(String title, String time, SafeL10n safeL10n) {
    return Dismissible(
      key: Key(title),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildSettingsScreen(SafeL10n safeL10n) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(safeL10n.profileTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: Text(safeL10n.themeSettingTitle),
          subtitle: Text(safeL10n.themeSettingSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(safeL10n.languageSettingTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(safeL10n.notificationSettingTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: Text(safeL10n.securitySettingTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(safeL10n.aboutSettingTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: Text(safeL10n.logoutButton),
          ),
        ),
      ],
    );
  }
}
