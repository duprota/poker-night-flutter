import 'package:poker_night/models/notification.dart';

/// Interface para serviços de notificação
/// 
/// Esta interface define os métodos que qualquer implementação de serviço
/// de notificação deve fornecer, permitindo trocar facilmente entre diferentes
/// provedores de notificação no futuro.
abstract class NotificationServiceInterface {
  /// Inicializa o serviço de notificação
  Future<void> initialize();
  
  /// Envia uma notificação para um usuário específico
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });
  
  /// Envia uma notificação para múltiplos usuários
  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });
  
  /// Agenda uma notificação para ser enviada em um momento específico
  Future<void> scheduleNotification({
    required String userId,
    required String title,
    required String message,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  });
  
  /// Cancela uma notificação agendada
  Future<void> cancelScheduledNotification(String notificationId);
  
  /// Obtém todas as notificações para um usuário específico
  Future<List<AppNotification>> getNotificationsForUser(String userId);
  
  /// Marca uma notificação como lida
  Future<void> markNotificationAsRead(String notificationId);
  
  /// Marca todas as notificações de um usuário como lidas
  Future<void> markAllNotificationsAsRead(String userId);
  
  /// Exclui uma notificação
  Future<void> deleteNotification(String notificationId);
  
  /// Configura um listener para novas notificações
  Stream<AppNotification> subscribeToNotifications(String userId);
  
  /// Remove um listener de notificações
  Future<void> unsubscribeFromNotifications();
  
  /// Verifica se as notificações estão habilitadas para o dispositivo
  Future<bool> areNotificationsEnabled();
  
  /// Solicita permissão para enviar notificações
  Future<bool> requestNotificationPermission();
}
