import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_notification_service.dart';
import 'package:poker_night/models/notification.dart';

// Mock para o serviço de notificação
class MockNotificationService extends Mock implements NotificationServiceInterface {}

// Mock específico para o serviço de notificação do Supabase
class MockSupabaseNotificationService extends Mock implements SupabaseNotificationService {}

// Dados de exemplo para testes
class NotificationTestData {
  static List<AppNotification> getSampleNotifications() {
    return [
      AppNotification(
        id: 'notification1',
        userId: 'user1',
        title: 'Convite para jogo',
        message: 'João convidou você para o jogo Poker Night #123',
        type: NotificationType.gameInvite,
        status: NotificationStatus.unread,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        data: {
          'game_id': 'game123',
          'inviter_name': 'João',
        },
        actionUrl: '/games/game123',
      ),
      AppNotification(
        id: 'notification2',
        userId: 'user1',
        title: 'Lembrete de jogo',
        message: 'Seu jogo Poker Night #456 está agendado para hoje às 20h',
        type: NotificationType.gameReminder,
        status: NotificationStatus.read,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        data: {
          'game_id': 'game456',
        },
        actionUrl: '/games/game456',
      ),
      AppNotification(
        id: 'notification3',
        userId: 'user1',
        title: 'Resultado de jogo',
        message: 'Você ficou em 2º lugar no jogo Poker Night #789',
        type: NotificationType.gameResult,
        status: NotificationStatus.unread,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        data: {
          'game_id': 'game789',
          'position': 2,
          'amount': 150.0,
        },
        actionUrl: '/games/game789/results',
      ),
    ];
  }
}
