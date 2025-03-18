/// Constants for Supabase configuration
class SupabaseConstants {
  // Private constructor to prevent instantiation
  SupabaseConstants._();

  // Credenciais do Supabase para o projeto Poker Night
  static const String supabaseUrl = 'https://xyzcompanyid.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBva2VybmlnaHRhcHAiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY4NTEyMzQ1NiwiZXhwIjoyMDAwNjk5NDU2fQ.exampleKeyForDemoPurposes';

  // Supabase table names
  static const String usersTable = 'users';
  static const String gamesTable = 'games';
  static const String playersTable = 'players';
  static const String gamePlayersTable = 'game_players';
  static const String gameTransactionsTable = 'game_transactions';
}
