import 'package:uuid/uuid.dart';

/// Enum para representar o tipo de notificação
enum NotificationType {
  gameInvite,    // Convite para um jogo
  gameReminder,  // Lembrete de jogo agendado
  gameUpdate,    // Atualização em um jogo (local, data, etc.)
  gameResult,    // Resultados de um jogo
  friendRequest, // Solicitação de amizade
  system,        // Notificação do sistema
  custom,        // Notificação personalizada
}

/// Enum para representar o status de uma notificação
enum NotificationStatus {
  unread,     // Não lida
  read,       // Lida
  archived,   // Arquivada
}

/// Modelo para representar uma notificação no aplicativo
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  
  AppNotification({
    String? id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.status = NotificationStatus.unread,
    DateTime? createdAt,
    this.scheduledFor,
    this.data,
    this.actionUrl,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  /// Criar uma AppNotification a partir de um JSON (para uso com Supabase)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      createdAt: DateTime.parse(json['created_at']),
      scheduledFor: json['scheduled_for'] != null 
          ? DateTime.parse(json['scheduled_for']) 
          : null,
      data: json['data'],
      actionUrl: json['action_url'],
    );
  }
  
  /// Converter AppNotification para JSON (para uso com Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'data': data,
      'action_url': actionUrl,
    };
  }
  
  /// Criar uma cópia da notificação com alterações
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
