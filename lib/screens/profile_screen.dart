import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:poker_night/widgets/notification_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          // Badge de notificação
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: NotificationBadge(
              onTap: () => context.push('/notifications'),
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Você precisa estar logado para ver seu perfil'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar e informações básicas
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            _getInitials(user.email ?? ''),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.email ?? 'Sem email',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildSubscriptionBadge(context, authState.subscriptionStatus),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Estatísticas do usuário (usando feature toggle)
                  _buildFeatureToggleSection(
                    context, 
                    ref,
                    feature: Feature.statistics,
                    title: 'Estatísticas',
                    child: _buildStatisticsSection(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Configurações
                  const Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () => context.push('/notifications'),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Idioma',
                    onTap: () {
                      // Navegação para configurações de idioma
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema',
                    onTap: () {
                      // Navegação para configurações de tema
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botão de logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: const Text('Sair'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Widget para exibir uma seção baseada em feature toggle
  Widget _buildFeatureToggleSection(
    BuildContext context, 
    WidgetRef ref, {
    required Feature feature,
    required String title,
    required Widget child,
  }) {
    final featureToggleState = ref.watch(featureToggleProvider);
    final isEnabled = featureToggleState.isEnabled(feature);
    final subscriptionLevel = featureToggleState.getRequiredSubscription(feature);
    final authState = ref.watch(authProvider);
    
    // Verificar se o usuário tem acesso à feature
    final hasAccess = isEnabled && ref.read(authProvider.notifier).hasAccess(subscriptionLevel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (!isEnabled)
              const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
            if (isEnabled && !hasAccess)
              Icon(
                Icons.workspace_premium,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasAccess)
          child
        else
          _buildFeatureLockedMessage(
            context,
            isEnabled: isEnabled,
            requiredSubscription: subscriptionLevel,
            currentSubscription: authState.subscriptionStatus,
          ),
      ],
    );
  }
  
  // Widget para exibir mensagem quando uma feature está bloqueada
  Widget _buildFeatureLockedMessage(
    BuildContext context, {
    required bool isEnabled,
    required String requiredSubscription,
    required String currentSubscription,
  }) {
    if (!isEnabled) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Esta funcionalidade não está disponível no momento.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Funcionalidade exclusiva para assinantes $requiredSubscription',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça upgrade da sua assinatura para desbloquear esta funcionalidade.',
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Navegação para tela de assinatura
                },
                child: const Text('Ver planos'),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // Widget para exibir estatísticas do usuário
  Widget _buildStatisticsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatisticItem(
              context,
              icon: Icons.sports_esports,
              title: 'Jogos Participados',
              value: '27',
            ),
            const Divider(),
            _buildStatisticItem(
              context,
              icon: Icons.emoji_events,
              title: 'Vitórias',
              value: '8',
            ),
            const Divider(),
            _buildStatisticItem(
              context,
              icon: Icons.attach_money,
              title: 'Saldo Total',
              value: 'R$ 1.250,00',
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget para exibir um item de estatística
  Widget _buildStatisticItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para exibir um item de configuração
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget para exibir o badge de assinatura
  Widget _buildSubscriptionBadge(BuildContext context, String status) {
    Color backgroundColor;
    String label;
    
    switch (status) {
      case 'free':
        backgroundColor = Colors.grey;
        label = 'Gratuito';
        break;
      case 'basic':
        backgroundColor = Colors.blue;
        label = 'Básico';
        break;
      case 'premium':
        backgroundColor = Colors.amber;
        label = 'Premium';
        break;
      default:
        backgroundColor = Colors.grey;
        label = 'Desconhecido';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Obter iniciais do email
  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    
    final username = email.split('@').first;
    if (username.isEmpty) return '?';
    
    return username.substring(0, 1).toUpperCase();
  }
}
