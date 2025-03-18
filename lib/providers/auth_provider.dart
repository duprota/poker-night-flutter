import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/services/supabase_service.dart';

/// Provider para o SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Enum para os status de assinatura
enum SubscriptionStatus {
  free,
  premium,
  pro,
}

/// Enum para as funcionalidades que requerem assinatura
enum SubscriptionFeature {
  createGame,
  joinGame,
  unlimitedPlayers,
  statistics,
  exportData,
  customThemes,
}

/// Estado do AuthProvider
class AuthState {
  final User? user;
  final String? errorMessage;
  final SubscriptionStatus subscriptionStatus;

  AuthState({
    this.user,
    this.errorMessage,
    this.subscriptionStatus = SubscriptionStatus.free,
  });

  /// Verifica se o usuário está anônimo (não autenticado)
  bool get isAnonymous => user == null;

  /// Cria uma cópia do estado com os valores especificados
  AuthState copyWith({
    User? user,
    String? errorMessage,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }

  /// Cria uma cópia do estado com o erro especificado
  AuthState withError(String message) {
    return copyWith(errorMessage: message);
  }

  /// Cria uma cópia do estado sem erro
  AuthState withoutError() {
    return AuthState(
      user: user,
      subscriptionStatus: subscriptionStatus,
    );
  }

  /// Cria uma cópia do estado para usuário anônimo
  AuthState asAnonymous() {
    return AuthState(
      subscriptionStatus: SubscriptionStatus.free,
    );
  }
}

/// Provider para o AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref, supabaseServiceProvider);
});

/// Notifier para o AuthProvider
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final Provider<SupabaseService> _supabaseServiceProvider;

  AuthNotifier(this._ref, this._supabaseServiceProvider) : super(AuthState());

  /// Getter para o SupabaseService
  SupabaseService get _supabaseService => _ref.read(_supabaseServiceProvider);

  /// Verifica a sessão do usuário
  Future<void> checkSession() async {
    try {
      final user = _supabaseService.getCurrentUser();

      if (user != null) {
        final subscriptionStatus = await _supabaseService.getUserSubscriptionStatus(user.id);
        state = state.copyWith(
          user: user,
          subscriptionStatus: subscriptionStatus,
        );
      } else {
        state = state.asAnonymous();
      }
    } catch (e) {
      state = state.asAnonymous().withError(e.toString());
    }
  }

  /// Faz login com email e senha
  Future<void> signIn(String email, String password) async {
    try {
      state = state.withoutError();

      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final subscriptionStatus = await _supabaseService.getUserSubscriptionStatus(response.user!.id);
        state = state.copyWith(
          user: response.user,
          subscriptionStatus: subscriptionStatus,
        );
      } else {
        state = state.asAnonymous().withError('Erro ao fazer login');
      }
    } catch (e) {
      state = state.asAnonymous().withError(e.toString());
    }
  }

  /// Faz cadastro com email e senha
  Future<void> signUp(String email, String password, String name) async {
    try {
      state = state.withoutError();

      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        final subscriptionStatus = await _supabaseService.getUserSubscriptionStatus(response.user!.id);
        state = state.copyWith(
          user: response.user,
          subscriptionStatus: subscriptionStatus,
        );
      } else {
        state = state.asAnonymous().withError('Erro ao fazer cadastro');
      }
    } catch (e) {
      state = state.asAnonymous().withError(e.toString());
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = state.asAnonymous();
    } catch (e) {
      state = state.withError(e.toString());
    }
  }

  /// Atualiza o status da assinatura
  Future<void> updateSubscription(SubscriptionStatus status) async {
    try {
      if (state.user != null) {
        await _supabaseService.updateUserSubscription(
          userId: state.user!.id,
          status: status,
        );
        state = state.copyWith(subscriptionStatus: status);
      }
    } catch (e) {
      state = state.withError(e.toString());
    }
  }

  /// Verifica se o usuário tem acesso a uma funcionalidade
  bool hasAccess(SubscriptionFeature feature) {
    if (state.isAnonymous) {
      return false;
    }

    switch (feature) {
      case SubscriptionFeature.createGame:
        // Disponível para todos os usuários autenticados
        return true;
      case SubscriptionFeature.joinGame:
        // Disponível para todos os usuários autenticados
        return true;
      case SubscriptionFeature.unlimitedPlayers:
        // Requer Premium ou Pro
        return state.subscriptionStatus == SubscriptionStatus.premium ||
            state.subscriptionStatus == SubscriptionStatus.pro;
      case SubscriptionFeature.statistics:
        // Requer Pro
        return state.subscriptionStatus == SubscriptionStatus.pro;
      case SubscriptionFeature.exportData:
        // Requer Pro
        return state.subscriptionStatus == SubscriptionStatus.pro;
      case SubscriptionFeature.customThemes:
        // Requer Premium ou Pro
        return state.subscriptionStatus == SubscriptionStatus.premium ||
            state.subscriptionStatus == SubscriptionStatus.pro;
      default:
        return false;
    }
  }
}
