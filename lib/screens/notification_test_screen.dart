import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/widgets/error_message.dart';

/// Tela para testar o envio de notificações
/// Esta tela é apenas para fins de desenvolvimento e teste
class NotificationTestScreen extends ConsumerWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teste de Notificações')),
        body: const Center(
          child: Text('Você precisa estar logado para testar notificações'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de Notificações')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enviar Notificação de Teste',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Notificação simples
            _buildNotificationCard(
              context,
              title: 'Notificação Simples',
              description: 'Envia uma notificação básica para o usuário atual',
              onSend: () => _sendSimpleNotification(context, ref, user.id),
              icon: Icons.notifications,
              color: Colors.blue,
            ),
            
            // Convite para jogo
            _buildNotificationCard(
              context,
              title: 'Convite para Jogo',
              description: 'Simula um convite para participar de um jogo',
              onSend: () => _sendGameInvite(context, ref, user.id),
              icon: Icons.sports_esports,
              color: Colors.green,
            ),
            
            // Lembrete de jogo
            _buildNotificationCard(
              context,
              title: 'Lembrete de Jogo',
              description: 'Simula um lembrete para um jogo agendado',
              onSend: () => _sendGameReminder(context, ref, user.id),
              icon: Icons.alarm,
              color: Colors.orange,
            ),
            
            // Atualização de jogo
            _buildNotificationCard(
              context,
              title: 'Atualização de Jogo',
              description: 'Simula uma atualização em um jogo existente',
              onSend: () => _sendGameUpdate(context, ref, user.id),
              icon: Icons.update,
              color: Colors.purple,
            ),
            
            // Resultado de jogo
            _buildNotificationCard(
              context,
              title: 'Resultado de Jogo',
              description: 'Simula o envio dos resultados de um jogo',
              onSend: () => _sendGameResult(context, ref, user.id),
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Gerenciamento de notificações
            const Text(
              'Gerenciar Notificações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(notificationProvider.notifier).loadNotifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar Notificações'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Marcar Todas como Lidas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status das notificações
            _buildNotificationStatus(context, ref),
          ],
        ),
      ),
    );
  }
  
  // Widget para exibir um card de notificação
  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onSend,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget para exibir o status das notificações
  Widget _buildNotificationStatus(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    
    if (notificationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (notificationState.errorMessage != null) {
      return ErrorMessage(
        message: notificationState.errorMessage!,
        onRetry: () => ref.read(notificationProvider.notifier).loadNotifications(),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status das Notificações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              context,
              label: 'Total de Notificações',
              value: notificationState.notifications.length.toString(),
            ),
            _buildStatusItem(
              context,
              label: 'Notificações Não Lidas',
              value: notificationState.unreadCount.toString(),
              isHighlighted: notificationState.unreadCount > 0,
            ),
            if (notificationState.notifications.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Última Notificação:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationState.notifications.first.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(notificationState.notifications.first.message),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Widget para exibir um item de status
  Widget _buildStatusItem(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlighted
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Enviar uma notificação simples
  void _sendSimpleNotification(BuildContext context, WidgetRef ref, String userId) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.sendNotification(
        userId: userId,
        title: 'Notificação de Teste',
        message: 'Esta é uma notificação de teste enviada em ${DateTime.now().toString()}',
        data: {
          'test': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      _showSuccessSnackBar(context, 'Notificação enviada com sucesso!');
      
      // Atualizar a lista de notificações
      ref.read(notificationProvider.notifier).loadNotifications();
    } catch (e) {
      _showErrorSnackBar(context, 'Erro ao enviar notificação: $e');
    }
  }
  
  // Enviar um convite para jogo
  void _sendGameInvite(BuildContext context, WidgetRef ref, String userId) async {
    try {
      await ref.read(notificationProvider.notifier).sendGameInvite(
        userId: userId,
        gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
        gameName: 'Poker Night #${(DateTime.now().millisecondsSinceEpoch % 1000)}',
        inviterName: 'Você (Teste)',
        gameDate: DateTime.now().add(const Duration(days: 2)),
      );
      
      _showSuccessSnackBar(context, 'Convite para jogo enviado com sucesso!');
      
      // Atualizar a lista de notificações
      ref.read(notificationProvider.notifier).loadNotifications();
    } catch (e) {
      _showErrorSnackBar(context, 'Erro ao enviar convite: $e');
    }
  }
  
  // Enviar um lembrete de jogo
  void _sendGameReminder(BuildContext context, WidgetRef ref, String userId) async {
    try {
      await ref.read(notificationProvider.notifier).sendGameReminders(
        userIds: [userId],
        gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
        gameName: 'Poker Night #${(DateTime.now().millisecondsSinceEpoch % 1000)}',
        gameDate: DateTime.now().add(const Duration(hours: 3)),
      );
      
      _showSuccessSnackBar(context, 'Lembrete de jogo enviado com sucesso!');
      
      // Atualizar a lista de notificações
      ref.read(notificationProvider.notifier).loadNotifications();
    } catch (e) {
      _showErrorSnackBar(context, 'Erro ao enviar lembrete: $e');
    }
  }
  
  // Enviar uma atualização de jogo
  void _sendGameUpdate(BuildContext context, WidgetRef ref, String userId) async {
    try {
      await ref.read(notificationProvider.notifier).sendGameUpdate(
        userIds: [userId],
        gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
        gameName: 'Poker Night #${(DateTime.now().millisecondsSinceEpoch % 1000)}',
        updateMessage: 'O local do jogo foi alterado para Casa do João',
      );
      
      _showSuccessSnackBar(context, 'Atualização de jogo enviada com sucesso!');
      
      // Atualizar a lista de notificações
      ref.read(notificationProvider.notifier).loadNotifications();
    } catch (e) {
      _showErrorSnackBar(context, 'Erro ao enviar atualização: $e');
    }
  }
  
  // Enviar um resultado de jogo
  void _sendGameResult(BuildContext context, WidgetRef ref, String userId) async {
    try {
      await ref.read(notificationProvider.notifier).sendGameResult(
        userIds: [userId],
        gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
        gameName: 'Poker Night #${(DateTime.now().millisecondsSinceEpoch % 1000)}',
        resultMessage: 'Você ficou em 2º lugar e ganhou R$ 150,00',
      );
      
      _showSuccessSnackBar(context, 'Resultado de jogo enviado com sucesso!');
      
      // Atualizar a lista de notificações
      ref.read(notificationProvider.notifier).loadNotifications();
    } catch (e) {
      _showErrorSnackBar(context, 'Erro ao enviar resultado: $e');
    }
  }
  
  // Exibir uma snackbar de sucesso
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Exibir uma snackbar de erro
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
