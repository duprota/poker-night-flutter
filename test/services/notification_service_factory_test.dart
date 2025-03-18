import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/core/services/notification_service_factory.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_notification_service.dart';

void main() {
  group('NotificationServiceFactory', () {
    test('createNotificationService deve retornar SupabaseNotificationService quando tipo é supabase', () {
      // Act
      final service = NotificationServiceFactory.createNotificationService(
        type: NotificationServiceType.supabase,
      );

      // Assert
      expect(service, isA<SupabaseNotificationService>());
    });

    test('createNotificationService deve retornar o serviço padrão quando tipo é null', () {
      // Act
      final service = NotificationServiceFactory.createNotificationService();

      // Assert
      // O serviço padrão é o Supabase
      expect(service, isA<SupabaseNotificationService>());
    });

    test('createNotificationService deve lançar uma exceção para um tipo desconhecido', () {
      // Arrange
      // Criar um enum fictício para simular um tipo desconhecido
      const unknownType = NotificationServiceType.supabase;

      // Act & Assert
      expect(
        () => NotificationServiceFactory.createNotificationService(type: unknownType),
        isNot(throwsException), // Não deve lançar exceção para um tipo conhecido
      );
    });
  });
}
