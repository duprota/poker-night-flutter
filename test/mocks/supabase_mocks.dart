import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks para o Supabase
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSupabaseAuth extends Mock implements SupabaseAuth {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}

// Classe para facilitar a criação de mocks do Supabase
class SupabaseMocks {
  static MockSupabaseClient createMockSupabaseClient() {
    final mockSupabaseClient = MockSupabaseClient();
    final mockGoTrueClient = MockGoTrueClient();
    final mockAuth = MockSupabaseAuth();
    final mockPostgrest = MockPostgrestClient();
    
    // Configurar comportamentos padrão
    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockSupabaseClient.from(any())).thenReturn(mockPostgrest);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => Stream.fromIterable([]),
    );
    
    return mockSupabaseClient;
  }
  
  // Método para criar um usuário mock
  static MockUser createMockUser({
    String id = 'test-user-id',
    String email = 'test@example.com',
    String? phone,
    bool emailConfirmed = true,
    bool phoneConfirmed = false,
  }) {
    final mockUser = MockUser();
    
    when(() => mockUser.id).thenReturn(id);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.phone).thenReturn(phone);
    when(() => mockUser.emailConfirmedAt).thenReturn(
      emailConfirmed ? DateTime.now() : null,
    );
    when(() => mockUser.phoneConfirmedAt).thenReturn(
      phoneConfirmed ? DateTime.now() : null,
    );
    when(() => mockUser.appMetadata).thenReturn({});
    when(() => mockUser.userMetadata).thenReturn({});
    
    return mockUser;
  }
  
  // Método para criar uma sessão mock
  static MockSession createMockSession({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    required MockUser user,
  }) {
    final mockSession = MockSession();
    
    when(() => mockSession.accessToken).thenReturn(accessToken);
    when(() => mockSession.refreshToken).thenReturn(refreshToken);
    when(() => mockSession.user).thenReturn(user);
    when(() => mockSession.expiresAt).thenReturn(
      DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
    
    return mockSession;
  }
}
