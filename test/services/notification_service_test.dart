import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_notification_service.dart';
import 'package:poker_night/models/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../mocks/notification_mocks.dart';

// Mock para o cliente Supabase
class MockSupabaseClient extends Mock implements SupabaseClient {}

// Mock para o cliente de banco de dados do Supabase
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late SupabaseNotificationService notificationService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    // Configurar o mock do cliente Supabase
    when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);

    // Inicializar o serviço de notificação com o mock
    notificationService = SupabaseNotificationService(client: mockSupabaseClient);
  });

  group('SupabaseNotificationService', () {
    test('initialize deve configurar o cliente e os listeners', () async {
      // Act
      await notificationService.initialize();

      // Assert
      // Verificar se o cliente foi configurado corretamente
      expect(notificationService.isInitialized, isTrue);
    });

    test('sendNotification deve criar uma nova notificação', () async {
      // Arrange
      final userId = 'user-123';
      final title = 'Teste de Notificação';
      final message = 'Esta é uma notificação de teste';
      final data = {'test': true};
      final type = NotificationType.system;
      
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) async => PostgrestResponse(
        data: {'id': 'new-notification-id'},
        status: 201,
        count: null,
        error: null,
        statusText: 'Created',
      ));

      // Act
      final result = await notificationService.sendNotification(
        userId: userId,
        title: title,
        message: message,
        data: data,
        type: type,
      );

      // Assert
      verify(() => mockQueryBuilder.insert(any())).called(1);
      expect(result, isNotNull);
      expect(result, isA<String>());
    });

    test('getNotifications deve retornar lista de notificações', () async {
      // Arrange
      final userId = 'user-123';
      final sampleNotifications = NotificationTestData.getSampleNotifications();
      final jsonList = sampleNotifications.map((n) => n.toJson()).toList();
      
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('user_id', userId)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.order('created_at', ascending: false)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.limit(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => PostgrestResponse(
        data: jsonList,
        status: 200,
        count: jsonList.length,
        error: null,
        statusText: 'OK',
      ));

      // Act
      final notifications = await notificationService.getNotifications(userId: userId);

      // Assert
      verify(() => mockQueryBuilder.select()).called(1);
      verify(() => mockQueryBuilder.eq('user_id', userId)).called(1);
      expect(notifications, hasLength(sampleNotifications.length));
      expect(notifications.first.id, equals(sampleNotifications.first.id));
    });

    test('markAsRead deve atualizar o status da notificação', () async {
      // Arrange
      final notificationId = 'notification-123';
      
      when(() => mockQueryBuilder.update(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('id', notificationId)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => PostgrestResponse(
        data: {'id': notificationId, 'status': 'read'},
        status: 200,
        count: 1,
        error: null,
        statusText: 'OK',
      ));

      // Act
      final result = await notificationService.markAsRead(notificationId: notificationId);

      // Assert
      verify(() => mockQueryBuilder.update({'status': 'read'})).called(1);
      verify(() => mockQueryBuilder.eq('id', notificationId)).called(1);
      expect(result, isTrue);
    });

    test('markAllAsRead deve atualizar o status de todas as notificações do usuário', () async {
      // Arrange
      final userId = 'user-123';
      
      when(() => mockQueryBuilder.update(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('user_id', userId)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('status', 'unread')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => PostgrestResponse(
        data: [{'status': 'read'}],
        status: 200,
        count: 3,
        error: null,
        statusText: 'OK',
      ));

      // Act
      final result = await notificationService.markAllAsRead(userId: userId);

      // Assert
      verify(() => mockQueryBuilder.update({'status': 'read'})).called(1);
      verify(() => mockQueryBuilder.eq('user_id', userId)).called(1);
      verify(() => mockQueryBuilder.eq('status', 'unread')).called(1);
      expect(result, isTrue);
    });

    test('deleteNotification deve remover a notificação', () async {
      // Arrange
      final notificationId = 'notification-123';
      
      when(() => mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('id', notificationId)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => PostgrestResponse(
        data: {'id': notificationId},
        status: 200,
        count: 1,
        error: null,
        statusText: 'OK',
      ));

      // Act
      final result = await notificationService.deleteNotification(notificationId: notificationId);

      // Assert
      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockQueryBuilder.eq('id', notificationId)).called(1);
      expect(result, isTrue);
    });

    test('getUnreadCount deve retornar o número de notificações não lidas', () async {
      // Arrange
      final userId = 'user-123';
      final unreadCount = 5;
      
      when(() => mockQueryBuilder.select('id')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('user_id', userId)).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq('status', 'unread')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => PostgrestResponse(
        data: List.generate(unreadCount, (index) => {'id': 'notification-$index'}),
        status: 200,
        count: unreadCount,
        error: null,
        statusText: 'OK',
      ));

      // Act
      final count = await notificationService.getUnreadCount(userId: userId);

      // Assert
      verify(() => mockQueryBuilder.select('id')).called(1);
      verify(() => mockQueryBuilder.eq('user_id', userId)).called(1);
      verify(() => mockQueryBuilder.eq('status', 'unread')).called(1);
      expect(count, equals(unreadCount));
    });
  });
}
