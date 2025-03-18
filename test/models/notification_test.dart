import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/models/notification.dart';

void main() {
  group('AppNotification', () {
    test('fromJson e toJson devem funcionar corretamente', () {
      // Arrange
      final notification = AppNotification(
        id: 'test-id',
        userId: 'user-123',
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        type: NotificationType.gameInvite,
        status: NotificationStatus.unread,
        createdAt: DateTime(2025, 3, 18, 10, 0, 0),
        data: {
          'game_id': 'game-123',
          'inviter_name': 'João',
        },
        actionUrl: '/games/game-123',
      );

      // Act
      final json = notification.toJson();
      final fromJson = AppNotification.fromJson(json);

      // Assert
      expect(fromJson.id, equals(notification.id));
      expect(fromJson.userId, equals(notification.userId));
      expect(fromJson.title, equals(notification.title));
      expect(fromJson.message, equals(notification.message));
      expect(fromJson.type, equals(notification.type));
      expect(fromJson.status, equals(notification.status));
      expect(fromJson.createdAt.toIso8601String(), equals(notification.createdAt.toIso8601String()));
      expect(fromJson.data, equals(notification.data));
      expect(fromJson.actionUrl, equals(notification.actionUrl));
    });

    test('copyWith deve criar uma cópia com os valores alterados', () {
      // Arrange
      final notification = AppNotification(
        id: 'test-id',
        userId: 'user-123',
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        type: NotificationType.gameInvite,
        status: NotificationStatus.unread,
        createdAt: DateTime(2025, 3, 18, 10, 0, 0),
        data: {
          'game_id': 'game-123',
        },
        actionUrl: '/games/game-123',
      );

      // Act
      final copied = notification.copyWith(
        status: NotificationStatus.read,
        title: 'Título Atualizado',
      );

      // Assert
      expect(copied.id, equals(notification.id));
      expect(copied.userId, equals(notification.userId));
      expect(copied.title, equals('Título Atualizado'));
      expect(copied.message, equals(notification.message));
      expect(copied.type, equals(notification.type));
      expect(copied.status, equals(NotificationStatus.read));
      expect(copied.createdAt, equals(notification.createdAt));
      expect(copied.data, equals(notification.data));
      expect(copied.actionUrl, equals(notification.actionUrl));
    });

    test('status deve ser unread por padrão', () {
      // Arrange & Act
      final notification = AppNotification(
        userId: 'user-123',
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        type: NotificationType.gameInvite,
      );

      // Assert
      expect(notification.status, equals(NotificationStatus.unread));
    });

    test('toJson deve converter corretamente os enums para string', () {
      // Arrange
      final notification = AppNotification(
        id: 'test-id',
        userId: 'user-123',
        title: 'Teste de Notificação',
        message: 'Esta é uma notificação de teste',
        type: NotificationType.gameInvite,
        status: NotificationStatus.unread,
      );

      // Act
      final json = notification.toJson();

      // Assert
      expect(json['type'], equals('gameInvite'));
      expect(json['status'], equals('unread'));
    });

    test('fromJson deve converter corretamente strings para enums', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'title': 'Teste de Notificação',
        'message': 'Esta é uma notificação de teste',
        'type': 'gameInvite',
        'status': 'read',
        'created_at': '2025-03-18T10:00:00.000',
      };

      // Act
      final notification = AppNotification.fromJson(json);

      // Assert
      expect(notification.type, equals(NotificationType.gameInvite));
      expect(notification.status, equals(NotificationStatus.read));
    });

    test('fromJson deve usar valores padrão para enums desconhecidos', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'title': 'Teste de Notificação',
        'message': 'Esta é uma notificação de teste',
        'type': 'unknown',
        'status': 'unknown',
        'created_at': '2025-03-18T10:00:00.000',
      };

      // Act
      final notification = AppNotification.fromJson(json);

      // Assert
      expect(notification.type, equals(NotificationType.system));
      expect(notification.status, equals(NotificationStatus.unread));
    });
  });
}
