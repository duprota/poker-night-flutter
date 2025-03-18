import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/deep_link_service_factory.dart';
import 'package:poker_night/core/services/deep_link_service_interface.dart';
import 'package:poker_night/providers/auth_provider.dart';

/// Provider para o serviço de deep link
final deepLinkServiceProvider = Provider<DeepLinkServiceInterface>((ref) {
  final deepLinkService = DeepLinkServiceFactory.createDeepLinkService();
  
  ref.onDispose(() {
    deepLinkService.dispose();
  });
  
  return deepLinkService;
});

/// Estado para o provider de deep link
class DeepLinkState {
  final Uri? lastProcessedLink;
  final bool isProcessing;
  final String? errorMessage;
  final Map<String, dynamic>? lastProcessedData;
  
  const DeepLinkState({
    this.lastProcessedLink,
    this.isProcessing = false,
    this.errorMessage,
    this.lastProcessedData,
  });
  
  DeepLinkState copyWith({
    Uri? lastProcessedLink,
    bool? isProcessing,
    String? errorMessage,
    Map<String, dynamic>? lastProcessedData,
  }) {
    return DeepLinkState(
      lastProcessedLink: lastProcessedLink ?? this.lastProcessedLink,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      lastProcessedData: lastProcessedData ?? this.lastProcessedData,
    );
  }
}

/// Notifier para o provider de deep link
class DeepLinkNotifier extends StateNotifier<DeepLinkState> {
  final DeepLinkServiceInterface _deepLinkService;
  final Reader _read;
  
  DeepLinkNotifier(this._deepLinkService, this._read) : super(const DeepLinkState()) {
    _initialize();
  }
  
  /// Inicializa o serviço de deep link e configura os handlers
  Future<void> _initialize() async {
    try {
      await _deepLinkService.initialize();
      _setupHandlers();
      
      // Escutar novos deep links
      _deepLinkService.deepLinkStream.listen((uri) {
        _processDeepLink(uri);
      });
    } catch (e) {
      debugPrint('Erro ao inicializar o serviço de deep link: $e');
    }
  }
  
  /// Configura os handlers para diferentes tipos de deep links
  void _setupHandlers() {
    // Handler para links de jogos
    _deepLinkService.registerHandler(
      path: '/game',
      handler: _handleGameLink,
    );
    
    // Handler para links de jogadores
    _deepLinkService.registerHandler(
      path: '/player',
      handler: _handlePlayerLink,
    );
    
    // Handler para links de notificações
    _deepLinkService.registerHandler(
      path: '/notification',
      handler: _handleNotificationLink,
    );
    
    // Handler para links de convites
    _deepLinkService.registerHandler(
      path: '/invite',
      handler: _handleInviteLink,
    );
  }
  
  /// Processa um deep link recebido
  Future<void> _processDeepLink(Uri uri) async {
    state = state.copyWith(
      isProcessing: true,
      errorMessage: null,
    );
    
    try {
      final success = await _deepLinkService.processDeepLink(uri);
      
      state = state.copyWith(
        lastProcessedLink: uri,
        isProcessing: false,
        errorMessage: success ? null : 'Não foi possível processar o link',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Erro ao processar o link: $e',
      );
    }
  }
  
  /// Cria um deep link para um recurso específico
  String createDeepLink({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) {
    return _deepLinkService.createDeepLink(
      path: path,
      queryParameters: queryParameters,
    );
  }
  
  /// Handler para links de jogos
  Future<bool> _handleGameLink(Uri uri) async {
    final gameId = uri.queryParameters['id'];
    if (gameId == null) {
      return false;
    }
    
    state = state.copyWith(
      lastProcessedData: {
        'type': DeepLinkType.game,
        'gameId': gameId,
      },
    );
    
    return true;
  }
  
  /// Handler para links de jogadores
  Future<bool> _handlePlayerLink(Uri uri) async {
    final playerId = uri.queryParameters['id'];
    if (playerId == null) {
      return false;
    }
    
    state = state.copyWith(
      lastProcessedData: {
        'type': DeepLinkType.player,
        'playerId': playerId,
      },
    );
    
    return true;
  }
  
  /// Handler para links de notificações
  Future<bool> _handleNotificationLink(Uri uri) async {
    final notificationId = uri.queryParameters['id'];
    if (notificationId == null) {
      return false;
    }
    
    state = state.copyWith(
      lastProcessedData: {
        'type': DeepLinkType.notification,
        'notificationId': notificationId,
      },
    );
    
    return true;
  }
  
  /// Handler para links de convites
  Future<bool> _handleInviteLink(Uri uri) async {
    final gameId = uri.queryParameters['gameId'];
    final inviterId = uri.queryParameters['inviterId'];
    
    if (gameId == null || inviterId == null) {
      return false;
    }
    
    // Verificar se o usuário está autenticado
    final authState = _read(authProvider);
    if (!authState.isAuthenticated) {
      // Armazenar o link para processamento após o login
      state = state.copyWith(
        lastProcessedData: {
          'type': DeepLinkType.invite,
          'gameId': gameId,
          'inviterId': inviterId,
          'pendingAuth': true,
        },
      );
      return true;
    }
    
    state = state.copyWith(
      lastProcessedData: {
        'type': DeepLinkType.invite,
        'gameId': gameId,
        'inviterId': inviterId,
      },
    );
    
    return true;
  }
}

/// Provider para o estado de deep link
final deepLinkProvider = StateNotifierProvider<DeepLinkNotifier, DeepLinkState>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  return DeepLinkNotifier(deepLinkService, ref.read);
});
