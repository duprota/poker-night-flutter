import 'package:flutter/foundation.dart';

/// Interface para o serviço de deep links
abstract class DeepLinkServiceInterface {
  /// Inicializa o serviço de deep links
  Future<void> initialize();
  
  /// Processa um deep link
  Future<bool> processDeepLink(Uri uri);
  
  /// Stream de deep links recebidos
  Stream<Uri> get deepLinkStream;
  
  /// Último deep link processado
  Uri? get lastDeepLink;
  
  /// Cria um deep link para um recurso específico
  String createDeepLink({
    required String path,
    Map<String, dynamic>? queryParameters,
  });
  
  /// Registra um handler para um tipo específico de deep link
  void registerHandler({
    required String path,
    required Future<bool> Function(Uri uri) handler,
  });
  
  /// Remove um handler registrado
  void unregisterHandler(String path);
  
  /// Desativa o serviço de deep links
  Future<void> dispose();
}

/// Enum para representar os tipos de deep links suportados
enum DeepLinkType {
  game,        // Detalhes de um jogo
  player,      // Perfil de um jogador
  notification, // Detalhes de uma notificação
  invite,      // Convite para um jogo
  settings,    // Configurações do app
  subscription, // Assinatura
  custom,      // Link personalizado
}

/// Classe para representar um resultado de processamento de deep link
class DeepLinkResult {
  final bool success;
  final String? errorMessage;
  final DeepLinkType? type;
  final Map<String, dynamic>? data;
  
  const DeepLinkResult({
    required this.success,
    this.errorMessage,
    this.type,
    this.data,
  });
  
  factory DeepLinkResult.success({
    required DeepLinkType type,
    Map<String, dynamic>? data,
  }) {
    return DeepLinkResult(
      success: true,
      type: type,
      data: data,
    );
  }
  
  factory DeepLinkResult.error(String message) {
    return DeepLinkResult(
      success: false,
      errorMessage: message,
    );
  }
}
