import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/notification_service_factory.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/models/notification.dart';

/// Estado para o provider de notificações
class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  /// Criar uma cópia do estado com alterações
  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifier para gerenciar o estado das notificações
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationServiceInterface _notificationService;
  final SupabaseService _supabaseService;
  
  NotificationNotifier(this._notificationService, this._supabaseService) 
      : super(const NotificationState()) {
    // Inicializar o serviço de notificação
    _initialize();
  }
  
  /// Inicializa o serviço de notificação e carrega as notificações
  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      await loadNotifications();
      
      // Configurar listener para novas notificações
      final currentUser = _supabaseService.getCurrentUser();
      if (currentUser != null) {
        _notificationService.subscribeToNotifications(currentUser.id).listen((notification) {
          _handleNewNotification(notification);
        });
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar serviço de notificação: $e',
        isLoading: false,
      );
    }
  }
  
  /// Carrega as notificações do usuário atual
  Future<void> loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final currentUser = _supabaseService.getCurrentUser();
      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          notifications: [],
          unreadCount: 0,
        );
        return;
      }
      
      final notifications = await _notificationService.getNotificationsForUser(currentUser.id);
      final unreadCount = notifications.where((n) => n.status == NotificationStatus.unread).length;
      
      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar notificações: $e',
      );
    }
  }
  
  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Atualizar o estado localmente
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(status: NotificationStatus.read);
        }
        return notification;
      }).toList();
      
      final unreadCount = updatedNotifications
          .where((n) => n.status == NotificationStatus.unread)
          .length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao marcar notificação como lida: $e',
      );
    }
  }
  
  /// Marca todas as notificações como lidas
  Future<void> markAllAsRead() async {
    try {
      final currentUser = _supabaseService.getCurrentUser();
      if (currentUser == null) return;
      
      await _notificationService.markAllNotificationsAsRead(currentUser.id);
      
      // Atualizar o estado localmente
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(status: NotificationStatus.read);
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao marcar todas as notificações como lidas: $e',
      );
    }
  }
  
  /// Exclui uma notificação
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Atualizar o estado localmente
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      final unreadCount = updatedNotifications
          .where((n) => n.status == NotificationStatus.unread)
          .length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao excluir notificação: $e',
      );
    }
  }
  
  /// Envia uma notificação de convite para jogo
  Future<void> sendGameInvite({
    required String userId,
    required String gameId,
    required String gameName,
    required String inviterName,
    required DateTime gameDate,
  }) async {
    try {
      if (_notificationService is SupabaseNotificationService) {
        await (_notificationService as SupabaseNotificationService).sendGameInviteNotification(
          userId: userId,
          gameId: gameId,
          gameName: gameName,
          inviterName: inviterName,
          gameDate: gameDate,
        );
      } else {
        await _notificationService.sendNotification(
          userId: userId,
          title: 'Convite para jogo',
          message: '$inviterName convidou você para o jogo $gameName',
          data: {
            'type': NotificationType.gameInvite.toString().split('.').last,
            'game_id': gameId,
            'inviter_name': inviterName,
            'game_date': gameDate.toIso8601String(),
          },
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar convite para jogo: $e',
      );
    }
  }
  
  /// Envia um lembrete de jogo para todos os jogadores
  Future<void> sendGameReminders({
    required List<String> userIds,
    required String gameId,
    required String gameName,
    required DateTime gameDate,
  }) async {
    try {
      for (final userId in userIds) {
        if (_notificationService is SupabaseNotificationService) {
          await (_notificationService as SupabaseNotificationService).sendGameReminderNotification(
            userId: userId,
            gameId: gameId,
            gameName: gameName,
            gameDate: gameDate,
          );
        } else {
          await _notificationService.sendNotification(
            userId: userId,
            title: 'Lembrete de jogo',
            message: 'Seu jogo $gameName está agendado para breve',
            data: {
              'type': NotificationType.gameReminder.toString().split('.').last,
              'game_id': gameId,
              'game_date': gameDate.toIso8601String(),
            },
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar lembretes de jogo: $e',
      );
    }
  }
  
  /// Envia uma notificação de atualização de jogo para todos os jogadores
  Future<void> sendGameUpdate({
    required List<String> userIds,
    required String gameId,
    required String gameName,
    required String updateMessage,
  }) async {
    try {
      if (_notificationService is SupabaseNotificationService) {
        await (_notificationService as SupabaseNotificationService).sendGameUpdateNotification(
          userIds: userIds,
          gameId: gameId,
          gameName: gameName,
          updateMessage: updateMessage,
        );
      } else {
        await _notificationService.sendBulkNotifications(
          userIds: userIds,
          title: 'Atualização de jogo',
          message: 'O jogo $gameName foi atualizado: $updateMessage',
          data: {
            'type': NotificationType.gameUpdate.toString().split('.').last,
            'game_id': gameId,
          },
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar atualização de jogo: $e',
      );
    }
  }
  
  /// Envia uma notificação de resultado de jogo para todos os jogadores
  Future<void> sendGameResult({
    required List<String> userIds,
    required String gameId,
    required String gameName,
    required String resultMessage,
  }) async {
    try {
      if (_notificationService is SupabaseNotificationService) {
        await (_notificationService as SupabaseNotificationService).sendGameResultNotification(
          userIds: userIds,
          gameId: gameId,
          gameName: gameName,
          resultMessage: resultMessage,
        );
      } else {
        await _notificationService.sendBulkNotifications(
          userIds: userIds,
          title: 'Resultado do jogo',
          message: 'Resultados do jogo $gameName: $resultMessage',
          data: {
            'type': NotificationType.gameResult.toString().split('.').last,
            'game_id': gameId,
          },
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar resultados de jogo: $e',
      );
    }
  }
  
  /// Manipula uma nova notificação recebida
  void _handleNewNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final unreadCount = updatedNotifications
        .where((n) => n.status == NotificationStatus.unread)
        .length;
    
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    );
  }
  
  @override
  void dispose() {
    _notificationService.unsubscribeFromNotifications();
    super.dispose();
  }
}

/// Provider para o serviço Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider para o serviço de notificação
final notificationServiceProvider = Provider<NotificationServiceInterface>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return NotificationServiceFactory.createNotificationService(
    NotificationServiceType.supabase,
    supabaseService: supabaseService,
  );
});

/// Provider para o estado das notificações
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final supabaseService = ref.read(supabaseServiceProvider);
  return NotificationNotifier(notificationService, supabaseService);
});
