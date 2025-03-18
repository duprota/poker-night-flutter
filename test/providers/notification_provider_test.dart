import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/notification_provider.dart';

import '../mocks/notification_mocks.dart';

// Mock para o estado de autenticação
class MockAuthState extends Mock implements AuthState {}

// Mock para o notifier de autenticação
class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  late MockNotificationService mockNotificationService;
  late MockAuthState mockAuthState;
  late MockAuthNotifier mockAuthNotifier;
  late ProviderContainer container;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockAuthState = MockAuthState();
    mockAuthNotifier = MockAuthNotifier();

    // Configurar o mock do serviço de notificação
    when(() => mockNotificationService.initialize()).thenAnswer((_) async {});
    
    // Configurar o mock do estado de autenticação
    when(() => mockAuthState.user).thenReturn(
      const User(id: 'user-123', email: 'teste@exemplo.com', subscriptionStatus: 'free')
    );
    when(() => mockAuthState.isAuthenticated).thenReturn(true);

    // Criar o container com os providers mockados
    container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        authProvider.overrideWithValue(
          StateNotifierProvider<AuthNotifier, AuthState>((ref) => mockAuthNotifier)
        ),
        authProvider.notifier.overrideWithValue(mockAuthNotifier),
      ],
    );

    // Configurar o mock do notifier de autenticação para retornar o estado mockado
    when(() => mockAuthNotifier.state).thenReturn(mockAuthState);
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationProvider', () {
    test('estado inicial deve ter lista vazia e isLoading=false', () {
      // Act
      final state = container.read(notificationProvider);

      // Assert
      expect(state.notifications, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.unreadCount, equals(0));
    });

    test('loadNotifications deve atualizar o estado com as notificações', () async {
      // Arrange
      final sampleNotifications = NotificationTestData.getSampleNotifications();
      
      when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleNotifications);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 2); // 2 notificações não lidas

      // Act
      await container.read(notificationProvider.notifier).loadNotifications();
      final state = container.read(notificationProvider);

      // Assert
      verify(() => mockNotificationService.getNotifications(userId: any(named: 'userId'))).called(1);
      verify(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId'))).called(1);
      
      expect(state.notifications, equals(sampleNotifications));
      expect(state.unreadCount, equals(2));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('loadNotifications deve definir errorMessage quando ocorrer um erro', () async {
      // Arrange
      when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
          .thenThrow(Exception('Erro ao carregar notificações'));

      // Act
      await container.read(notificationProvider.notifier).loadNotifications();
      final state = container.read(notificationProvider);

      // Assert
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('markAsRead deve atualizar o status da notificação para lida', () async {
      // Arrange
      final sampleNotifications = NotificationTestData.getSampleNotifications();
      final notificationToMark = sampleNotifications.first;
      
      // Configurar o estado inicial com as notificações de exemplo
      when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleNotifications);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 2);
      
      await container.read(notificationProvider.notifier).loadNotifications();
      
      // Configurar o mock para marcar como lida
      when(() => mockNotificationService.markAsRead(notificationId: notificationToMark.id))
          .thenAnswer((_) async => true);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 1); // Agora temos 1 notificação não lida

      // Act
      await container.read(notificationProvider.notifier).markAsRead(notificationToMark.id);
      final state = container.read(notificationProvider);

      // Assert
      verify(() => mockNotificationService.markAsRead(notificationId: notificationToMark.id)).called(1);
      verify(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId'))).called(2); // Uma vez no loadNotifications e outra no markAsRead
      
      // Verificar se a notificação foi marcada como lida no estado
      final updatedNotification = state.notifications.firstWhere((n) => n.id == notificationToMark.id);
      expect(updatedNotification.status, equals(NotificationStatus.read));
      expect(state.unreadCount, equals(1));
    });

    test('markAllAsRead deve marcar todas as notificações como lidas', () async {
      // Arrange
      final sampleNotifications = NotificationTestData.getSampleNotifications();
      
      // Configurar o estado inicial com as notificações de exemplo
      when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleNotifications);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 2);
      
      await container.read(notificationProvider.notifier).loadNotifications();
      
      // Configurar o mock para marcar todas como lidas
      when(() => mockNotificationService.markAllAsRead(userId: any(named: 'userId')))
          .thenAnswer((_) async => true);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 0); // Agora não temos notificações não lidas

      // Act
      await container.read(notificationProvider.notifier).markAllAsRead();
      final state = container.read(notificationProvider);

      // Assert
      verify(() => mockNotificationService.markAllAsRead(userId: any(named: 'userId'))).called(1);
      
      // Verificar se todas as notificações foram marcadas como lidas no estado
      for (final notification in state.notifications) {
        expect(notification.status, equals(NotificationStatus.read));
      }
      expect(state.unreadCount, equals(0));
    });

    test('deleteNotification deve remover a notificação da lista', () async {
      // Arrange
      final sampleNotifications = NotificationTestData.getSampleNotifications();
      final notificationToDelete = sampleNotifications.first;
      
      // Configurar o estado inicial com as notificações de exemplo
      when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleNotifications);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 2);
      
      await container.read(notificationProvider.notifier).loadNotifications();
      
      // Configurar o mock para deletar a notificação
      when(() => mockNotificationService.deleteNotification(notificationId: notificationToDelete.id))
          .thenAnswer((_) async => true);
      
      when(() => mockNotificationService.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 1); // Agora temos 1 notificação não lida

      // Act
      await container.read(notificationProvider.notifier).deleteNotification(notificationToDelete.id);
      final state = container.read(notificationProvider);

      // Assert
      verify(() => mockNotificationService.deleteNotification(notificationId: notificationToDelete.id)).called(1);
      
      // Verificar se a notificação foi removida da lista
      expect(state.notifications, hasLength(sampleNotifications.length - 1));
      expect(state.notifications.any((n) => n.id == notificationToDelete.id), isFalse);
      expect(state.unreadCount, equals(1));
    });

    test('sendGameInvite deve enviar uma notificação de convite para jogo', () async {
      // Arrange
      final userId = 'user-456';
      final gameId = 'game-123';
      final gameName = 'Poker Night #123';
      final inviterName = 'João';
      final gameDate = DateTime(2025, 3, 20, 20, 0);
      
      when(() => mockNotificationService.sendNotification(
        userId: userId,
        title: any(named: 'title'),
        message: any(named: 'message'),
        type: NotificationType.gameInvite,
        data: any(named: 'data'),
        actionUrl: any(named: 'actionUrl'),
      )).thenAnswer((_) async => 'new-notification-id');

      // Act
      final result = await container.read(notificationProvider.notifier).sendGameInvite(
        userId: userId,
        gameId: gameId,
        gameName: gameName,
        inviterName: inviterName,
        gameDate: gameDate,
      );

      // Assert
      verify(() => mockNotificationService.sendNotification(
        userId: userId,
        title: any(named: 'title'),
        message: any(named: 'message'),
        type: NotificationType.gameInvite,
        data: any(named: 'data'),
        actionUrl: any(named: 'actionUrl'),
      )).called(1);
      
      expect(result, isTrue);
    });

    test('sendGameReminders deve enviar lembretes para múltiplos usuários', () async {
      // Arrange
      final userIds = ['user-123', 'user-456', 'user-789'];
      final gameId = 'game-123';
      final gameName = 'Poker Night #123';
      final gameDate = DateTime(2025, 3, 20, 20, 0);
      
      for (final userId in userIds) {
        when(() => mockNotificationService.sendNotification(
          userId: userId,
          title: any(named: 'title'),
          message: any(named: 'message'),
          type: NotificationType.gameReminder,
          data: any(named: 'data'),
          actionUrl: any(named: 'actionUrl'),
        )).thenAnswer((_) async => 'new-notification-id-$userId');
      }

      // Act
      final result = await container.read(notificationProvider.notifier).sendGameReminders(
        userIds: userIds,
        gameId: gameId,
        gameName: gameName,
        gameDate: gameDate,
      );

      // Assert
      for (final userId in userIds) {
        verify(() => mockNotificationService.sendNotification(
          userId: userId,
          title: any(named: 'title'),
          message: any(named: 'message'),
          type: NotificationType.gameReminder,
          data: any(named: 'data'),
          actionUrl: any(named: 'actionUrl'),
        )).called(1);
      }
      
      expect(result, isTrue);
    });
  });
}
