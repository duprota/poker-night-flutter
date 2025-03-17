import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final String? errorMessage;
  final bool isAnonymous;
  
  AuthState({this.user, this.errorMessage, this.isAnonymous = true});
  
  AuthState copyWith({User? user, String? errorMessage, bool? isAnonymous}) {
    return AuthState(
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
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
      state = AuthState(user: session.user, isAnonymous: false);
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
        state = AuthState(user: response.user, isAnonymous: false);
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
        },
      );
      
      if (response.session != null) {
        state = AuthState(user: response.user, isAnonymous: false);
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
}
