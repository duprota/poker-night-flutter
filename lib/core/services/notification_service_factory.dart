import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/core/services/supabase_notification_service.dart';
import 'package:poker_night/core/services/supabase_service.dart';

/// Enum para representar os diferentes tipos de serviços de notificação
enum NotificationServiceType {
  supabase,
  firebase,
  custom,
}

/// Factory para criar instâncias de serviços de notificação
class NotificationServiceFactory {
  /// Cria uma instância do serviço de notificação com base no tipo especificado
  static NotificationServiceInterface createNotificationService(
    NotificationServiceType type, {
    SupabaseService? supabaseService,
  }) {
    switch (type) {
      case NotificationServiceType.supabase:
        if (supabaseService == null) {
          throw ArgumentError('SupabaseService é necessário para criar um SupabaseNotificationService');
        }
        return SupabaseNotificationService(supabaseService);
      
      case NotificationServiceType.firebase:
        // Implementação futura
        throw UnimplementedError('Serviço de notificação Firebase ainda não implementado');
      
      case NotificationServiceType.custom:
        // Implementação futura
        throw UnimplementedError('Serviço de notificação personalizado ainda não implementado');
      
      default:
        throw ArgumentError('Tipo de serviço de notificação não suportado');
    }
  }
}
