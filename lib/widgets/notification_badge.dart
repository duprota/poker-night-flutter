import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/providers/notification_provider.dart';

/// Widget que exibe um ícone de notificação com um badge indicando 
/// o número de notificações não lidas
class NotificationBadge extends ConsumerWidget {
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final double badgeSize;

  const NotificationBadge({
    Key? key,
    required this.onTap,
    this.color,
    this.size = 24.0,
    this.badgeSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_outlined,
            color: color ?? Theme.of(context).iconTheme.color,
            size: size,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(badgeSize / 2),
                ),
                constraints: BoxConstraints(
                  minWidth: badgeSize,
                  minHeight: badgeSize,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: badgeSize * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
