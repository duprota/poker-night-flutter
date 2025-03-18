import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/models/notification.dart';

/// Implementação do serviço de notificação usando Supabase
class SupabaseNotificationService implements NotificationServiceInterface {
  final SupabaseService _supabaseService;
  final String _notificationsTable = 'notifications';
  RealtimeChannel? _notificationsChannel;
  final StreamController<AppNotification> _notificationsController = 
      StreamController<AppNotification>.broadcast();

  SupabaseNotificationService(this._supabaseService);

  @override
  Future<void> initialize() async {
    // Verificar se o usuário está autenticado
    final currentUser = _supabaseService.getCurrentUser();
    if (currentUser != null) {
      // Iniciar a escuta de notificações em tempo real
      await _setupRealtimeListener(currentUser.id);
    }
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.custom,
      data: data,
    );

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notification.toJson());
  }

  @override
  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notifications = userIds.map((userId) => 
      AppNotification(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.custom,
        data: data,
      ).toJson()
    ).toList();

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notifications);
  }

  @override
  Future<void> scheduleNotification({
    required String userId,
    required String title,
    required String message,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.custom,
      scheduledFor: scheduledTime,
      data: data,
    );

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notification.toJson());
  }

  @override
  Future<void> cancelScheduledNotification(String notificationId) async {
    await _supabaseService.client
        .from(_notificationsTable)
        .delete()
        .eq('id', notificationId)
        .eq('status', NotificationStatus.unread.toString().split('.').last);
  }

  @override
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    final response = await _supabaseService.client
        .from(_notificationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _supabaseService.client
        .from(_notificationsTable)
        .update({
          'status': NotificationStatus.read.toString().split('.').last
        })
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    await _supabaseService.client
        .from(_notificationsTable)
        .update({
          'status': NotificationStatus.read.toString().split('.').last
        })
        .eq('user_id', userId)
        .eq('status', NotificationStatus.unread.toString().split('.').last);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _supabaseService.client
        .from(_notificationsTable)
        .delete()
        .eq('id', notificationId);
  }

  @override
  Stream<AppNotification> subscribeToNotifications(String userId) {
    _setupRealtimeListener(userId);
    return _notificationsController.stream;
  }

  @override
  Future<void> unsubscribeFromNotifications() async {
    await _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    // Implementação específica da plataforma para verificar permissões
    // Por enquanto, retornamos true para simplificar
    return true;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    // Implementação específica da plataforma para solicitar permissões
    // Por enquanto, retornamos true para simplificar
    return true;
  }

  /// Configura um listener em tempo real para novas notificações
  Future<void> _setupRealtimeListener(String userId) async {
    // Cancelar qualquer inscrição existente
    await unsubscribeFromNotifications();
    
    try {
      _notificationsChannel = _supabaseService.client
          .channel('notifications_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: _notificationsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              final notification = AppNotification.fromJson(payload.newRecord);
              _notificationsController.add(notification);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Erro ao configurar listener de notificações: $e');
    }
  }

  /// Método para enviar uma notificação de convite para jogo
  Future<void> sendGameInviteNotification({
    required String userId,
    required String gameId,
    required String gameName,
    required String inviterName,
    required DateTime gameDate,
  }) async {
    final notification = AppNotification(
      userId: userId,
      title: 'Convite para jogo',
      message: '$inviterName convidou você para o jogo $gameName em ${_formatDate(gameDate)}',
      type: NotificationType.gameInvite,
      data: {
        'game_id': gameId,
        'inviter_name': inviterName,
      },
      actionUrl: '/games/$gameId',
    );

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notification.toJson());
  }

  /// Método para enviar um lembrete de jogo
  Future<void> sendGameReminderNotification({
    required String userId,
    required String gameId,
    required String gameName,
    required DateTime gameDate,
  }) async {
    final notification = AppNotification(
      userId: userId,
      title: 'Lembrete de jogo',
      message: 'Seu jogo $gameName está agendado para ${_formatDate(gameDate)}',
      type: NotificationType.gameReminder,
      data: {
        'game_id': gameId,
      },
      actionUrl: '/games/$gameId',
    );

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notification.toJson());
  }

  /// Método para enviar uma notificação de atualização de jogo
  Future<void> sendGameUpdateNotification({
    required List<String> userIds,
    required String gameId,
    required String gameName,
    required String updateMessage,
  }) async {
    final notifications = userIds.map((userId) => 
      AppNotification(
        userId: userId,
        title: 'Atualização de jogo',
        message: 'O jogo $gameName foi atualizado: $updateMessage',
        type: NotificationType.gameUpdate,
        data: {
          'game_id': gameId,
        },
        actionUrl: '/games/$gameId',
      ).toJson()
    ).toList();

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notifications);
  }

  /// Método para enviar uma notificação de resultado de jogo
  Future<void> sendGameResultNotification({
    required List<String> userIds,
    required String gameId,
    required String gameName,
    required String resultMessage,
  }) async {
    final notifications = userIds.map((userId) => 
      AppNotification(
        userId: userId,
        title: 'Resultado do jogo',
        message: 'Resultados do jogo $gameName: $resultMessage',
        type: NotificationType.gameResult,
        data: {
          'game_id': gameId,
        },
        actionUrl: '/games/$gameId/results',
      ).toJson()
    ).toList();

    await _supabaseService.client
        .from(_notificationsTable)
        .insert(notifications);
  }

  /// Formata uma data para exibição
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
