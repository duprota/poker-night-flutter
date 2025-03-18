import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    final localeNotifier = ref.read(localeProvider.notifier);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBarWidget(
        title: safeL10n.settingsTitle,
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Seção de Perfil
          if (!authState.isAnonymous) ...[
            _buildSectionTitle(safeL10n.profileTitle),
            _buildSettingCard(
              icon: Icons.person,
              title: safeL10n.profileTitle,
              subtitle: authState.user?.email ?? '',
              onTap: () {
                // Navegar para a tela de perfil
                context.push('/profile');
              },
            ),
            const SizedBox(height: 24),
          ],
          
          // Seção de Aparência
          _buildSectionTitle(safeL10n.themeSettingTitle),
          _buildSettingCard(
            icon: Icons.language,
            title: safeL10n.languageSettingTitle,
            subtitle: localeNotifier.getCurrentLanguageName(),
            onTap: () {
              // Navegar para a tela de configuração de idioma
              context.push('/settings/language');
            },
          ),
          _buildSettingCard(
            icon: Icons.dark_mode,
            title: safeL10n.themeSettingTitle,
            subtitle: safeL10n.darkThemeOption,
            onTap: () {
              // Navegar para a tela de configuração de tema (a ser implementada)
              // context.push('/settings/theme');
            },
          ),
          const SizedBox(height: 24),
          
          // Seção de Assinatura
          if (!authState.isAnonymous) ...[
            _buildSectionTitle(safeL10n.subscriptionCurrentPlan),
            _buildSettingCard(
              icon: Icons.card_membership,
              title: _getSubscriptionTitle(safeL10n, authState.subscriptionStatus),
              subtitle: _getSubscriptionDescription(safeL10n, authState.subscriptionStatus),
              onTap: () {
                // Navegar para a tela de assinaturas
                context.push('/subscriptions');
              },
            ),
            const SizedBox(height: 24),
          ],
          
          // Seção de Informações
          _buildSectionTitle(safeL10n.aboutSettingTitle),
          _buildSettingCard(
            icon: Icons.info,
            title: safeL10n.aboutSettingTitle,
            subtitle: 'Poker Night v1.0.0',
            onTap: () {
              // Mostrar informações sobre o aplicativo
              // context.push('/about');
            },
          ),
          _buildSettingCard(
            icon: Icons.privacy_tip,
            title: safeL10n.privacySettingTitle,
            subtitle: '',
            onTap: () {
              // Mostrar política de privacidade
              // context.push('/privacy');
            },
          ),
          const SizedBox(height: 24),
          
          // Botão de Logout
          if (!authState.isAnonymous) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(safeL10n.logoutButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8B5CF6),
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF222222),
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0, 
          vertical: 8.0
        ),
        leading: Icon(
          icon,
          color: const Color(0xFF8B5CF6),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14.0,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF8B5CF6),
          size: 16.0,
        ),
        onTap: onTap,
      ),
    );
  }
  
  String _getSubscriptionTitle(SafeL10n l10n, SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return l10n.get('subscriptionFree', 'Free Plan');
      case SubscriptionStatus.premium:
        return l10n.get('subscriptionPremium', 'Premium Plan');
      case SubscriptionStatus.pro:
        return l10n.get('subscriptionPro', 'Pro Plan');
      default:
        return '';
    }
  }
  
  String _getSubscriptionDescription(SafeL10n l10n, SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return '8 jogadores, 5 jogos';
      case SubscriptionStatus.premium:
        return '20 jogadores, 50 jogos, exportação';
      case SubscriptionStatus.pro:
        return 'Jogadores e jogos ilimitados, estatísticas avançadas';
      default:
        return '';
    }
  }
}
