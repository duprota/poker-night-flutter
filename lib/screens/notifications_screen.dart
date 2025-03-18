import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/widgets/error_message.dart';
import 'package:poker_night/widgets/loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marcar todas como lidas',
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
            ),
        ],
      ),
      body: _buildBody(context, notificationState, ref),
    );
  }
  
  Widget _buildBody(BuildContext context, NotificationState state, WidgetRef ref) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }
    
    if (state.errorMessage != null) {
      return ErrorMessage(
        message: state.errorMessage!,
        onRetry: () => ref.read(notificationProvider.notifier).loadNotifications(),
      );
    }
    
    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Você não tem notificações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).loadNotifications(),
              child: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(notificationProvider.notifier).loadNotifications(),
      child: ListView.builder(
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return NotificationItem(
            notification: notification,
            onMarkAsRead: () {
              ref.read(notificationProvider.notifier).markAsRead(notification.id);
            },
            onDelete: () {
              ref.read(notificationProvider.notifier).deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.status == NotificationStatus.unread;
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        elevation: isUnread ? 2.0 : 0.5,
        color: isUnread 
            ? Theme.of(context).colorScheme.primaryContainer 
            : Theme.of(context).cardColor,
        child: InkWell(
          onTap: () {
            if (isUnread) {
              onMarkAsRead();
            }
            
            // Navegar para a tela apropriada com base no tipo de notificação
            if (notification.actionUrl != null) {
              // Implementar navegação com base no actionUrl
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navegando para: ${notification.actionUrl}')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildNotificationIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      timeago.format(notification.createdAt, locale: 'pt_BR'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: isUnread 
                        ? Theme.of(context).textTheme.bodyLarge?.color 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onMarkAsRead,
                      child: const Text('Marcar como lida'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.gameInvite:
        iconData = Icons.sports_esports;
        iconColor = Colors.green;
        break;
      case NotificationType.gameReminder:
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case NotificationType.gameUpdate:
        iconData = Icons.update;
        iconColor = Colors.blue;
        break;
      case NotificationType.gameResult:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case NotificationType.friendRequest:
        iconData = Icons.person_add;
        iconColor = Colors.purple;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.grey;
        break;
      case NotificationType.custom:
      default:
        iconData = Icons.notifications;
        iconColor = Colors.teal;
        break;
    }
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(
        iconData,
        size: 18,
        color: iconColor,
      ),
    );
  }
}
