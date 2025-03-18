import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:poker_night/core/services/deep_link_service_interface.dart';

/// Implementação do serviço de deep links usando o pacote app_links
class AppLinksDeepLinkService implements DeepLinkServiceInterface {
  final AppLinks _appLinks = AppLinks();
  final Map<String, Future<bool> Function(Uri uri)> _handlers = {};
  final StreamController<Uri> _deepLinkStreamController = StreamController<Uri>.broadcast();
  Uri? _lastDeepLink;
  bool _isInitialized = false;
  
  @override
  Uri? get lastDeepLink => _lastDeepLink;
  
  @override
  Stream<Uri> get deepLinkStream => _deepLinkStreamController.stream;
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configurar listeners para links recebidos
      _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      });
      
      // Verificar se o app foi aberto por um link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erro ao inicializar o serviço de deep links: $e');
      rethrow;
    }
  }
  
  @override
  Future<bool> processDeepLink(Uri uri) async {
    return _handleDeepLink(uri);
  }
  
  @override
  String createDeepLink({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = Uri(
      scheme: 'pokernight',
      host: 'app',
      path: path,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    
    return uri.toString();
  }
  
  @override
  void registerHandler({
    required String path,
    required Future<bool> Function(Uri uri) handler,
  }) {
    _handlers[path] = handler;
  }
  
  @override
  void unregisterHandler(String path) {
    _handlers.remove(path);
  }
  
  @override
  Future<void> dispose() async {
    await _deepLinkStreamController.close();
    _handlers.clear();
    _isInitialized = false;
  }
  
  /// Processa um deep link recebido
  Future<bool> _handleDeepLink(Uri uri) async {
    // Evitar processar o mesmo deep link repetidamente
    if (_lastDeepLink != null && _lastDeepLink.toString() == uri.toString()) {
      return true;
    }
    
    _lastDeepLink = uri;
    _deepLinkStreamController.add(uri);
    
    // Em modo web, limitar os logs para evitar poluição do console
    if (!kIsWeb || uri.path.isNotEmpty && uri.path != '/') {
      debugPrint('Deep link recebido: $uri');
    }
    
    // Verificar se temos um handler registrado para este path
    final path = uri.path;
    
    // Ignorar deep links para a rota raiz quando estamos em modo web
    if (kIsWeb && (path.isEmpty || path == '/')) {
      return true;
    }
    
    if (_handlers.containsKey(path)) {
      return await _handlers[path]!(uri);
    }
    
    // Verificar se temos um handler para path parcial
    for (final entry in _handlers.entries) {
      if (path.startsWith(entry.key)) {
        return await entry.value(uri);
      }
    }
    
    // Limitar logs de erros em modo web para evitar poluição do console
    if (!kIsWeb || path.isNotEmpty && path != '/') {
      debugPrint('Nenhum handler encontrado para o path: $path');
    }
    return false;
  }
}
