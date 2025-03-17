import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Enum para representar os diferentes status de assinatura
enum SubscriptionStatus {
  free,    // Acesso básico gratuito
  premium, // Acesso intermediário pago
  pro      // Acesso completo pago
}

class AuthState {
  final User? user;
  final String? errorMessage;
  final bool isAnonymous;
  final SubscriptionStatus subscriptionStatus;
  
  AuthState({
    this.user, 
    this.errorMessage, 
    this.isAnonymous = true,
    this.subscriptionStatus = SubscriptionStatus.free,
  });
  
  AuthState copyWith({
    User? user, 
    String? errorMessage, 
    bool? isAnonymous,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Verificar sessão ao inicializar
    checkSession();
  }
  
  // Obter o cliente Supabase
  final supabase = Supabase.instance.client;

  // Verificar se o usuário está autenticado
  Future<void> checkSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      // Buscar o status da assinatura do usuário
      final subscriptionStatus = await _getSubscriptionStatus(session.user.id);
      state = AuthState(
        user: session.user, 
        isAnonymous: false,
        subscriptionStatus: subscriptionStatus,
      );
    } else {
      state = AuthState(isAnonymous: true);
    }
  }

  // Login com email e senha
  Future<void> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session != null) {
        // Buscar o status da assinatura do usuário
        final subscriptionStatus = await _getSubscriptionStatus(response.user!.id);
        state = AuthState(
          user: response.user, 
          isAnonymous: false,
          subscriptionStatus: subscriptionStatus,
        );
      } else {
        state = AuthState(errorMessage: "Falha ao fazer login", isAnonymous: true);
      }
    } catch (e) {
      state = AuthState(errorMessage: "Erro: ${e.toString()}", isAnonymous: true);
    }
  }

  // Registro de novo usuário
  Future<void> signUp(String email, String password, String? phone) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'phone': phone,
          'subscription_status': 'free', // Definir o status inicial como free
        },
      );
      
      if (response.session != null) {
        state = AuthState(
          user: response.user, 
          isAnonymous: false,
          subscriptionStatus: SubscriptionStatus.free, // Usuários novos começam com plano free
        );
        
        // Criar um registro na tabela de assinaturas (se necessário)
        await _createSubscriptionRecord(response.user!.id);
      } else {
        state = AuthState(errorMessage: "Falha ao criar conta", isAnonymous: true);
      }
    } catch (e) {
      state = AuthState(errorMessage: "Erro: ${e.toString()}", isAnonymous: true);
    }
  }

  // Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
    state = AuthState(isAnonymous: true);
  }
  
  // Atualizar o status da assinatura do usuário
  Future<void> updateSubscription(SubscriptionStatus newStatus) async {
    if (state.user == null) {
      state = state.copyWith(errorMessage: "Usuário não autenticado");
      return;
    }
    
    try {
      // Atualizar o status da assinatura no banco de dados
      await supabase
          .from('user_subscriptions')
          .update({'status': newStatus.toString().split('.').last})
          .eq('user_id', state.user!.id);
      
      // Atualizar o estado local
      state = state.copyWith(subscriptionStatus: newStatus);
    } catch (e) {
      state = state.copyWith(errorMessage: "Erro ao atualizar assinatura: ${e.toString()}");
    }
  }
  
  // Verificar se o usuário tem acesso a uma determinada funcionalidade
  bool hasAccess(SubscriptionFeature feature) {
    switch (feature) {
      case SubscriptionFeature.createGame:
        // Todos os usuários autenticados podem criar jogos
        return !state.isAnonymous;
      
      case SubscriptionFeature.unlimitedPlayers:
        // Apenas usuários premium e pro podem ter jogadores ilimitados
        return state.subscriptionStatus == SubscriptionStatus.premium || 
               state.subscriptionStatus == SubscriptionStatus.pro;
      
      case SubscriptionFeature.statistics:
        // Apenas usuários pro têm acesso a estatísticas avançadas
        return state.subscriptionStatus == SubscriptionStatus.pro;
      
      default:
        return false;
    }
  }
  
  // Buscar o status da assinatura do usuário do banco de dados
  Future<SubscriptionStatus> _getSubscriptionStatus(String userId) async {
    try {
      final response = await supabase
          .from('user_subscriptions')
          .select('status')
          .eq('user_id', userId)
          .single();
      
      final status = response['status'] as String;
      
      switch (status) {
        case 'premium':
          return SubscriptionStatus.premium;
        case 'pro':
          return SubscriptionStatus.pro;
        default:
          return SubscriptionStatus.free;
      }
    } catch (e) {
      // Se ocorrer um erro ou o usuário não tiver um registro de assinatura,
      // retornar o status free
      return SubscriptionStatus.free;
    }
  }
  
  // Criar um registro de assinatura para um novo usuário
  Future<void> _createSubscriptionRecord(String userId) async {
    try {
      await supabase.from('user_subscriptions').insert({
        'user_id': userId,
        'status': 'free',
        'start_date': DateTime.now().toIso8601String(),
        'end_date': null, // Plano free não tem data de término
      });
    } catch (e) {
      print('Erro ao criar registro de assinatura: ${e.toString()}');
    }
  }
}

// Enum para representar as funcionalidades que podem ser restritas por assinatura
enum SubscriptionFeature {
  createGame,       // Criar um jogo
  unlimitedPlayers, // Ter jogadores ilimitados em um jogo
  statistics,       // Acessar estatísticas avançadas
}
