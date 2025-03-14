/// Constants for Supabase configuration
class SupabaseConstants {
  // Private constructor to prevent instantiation
  SupabaseConstants._();

  // TODO: Replace with your actual Supabase URL and anon key
  // You'll need to create a Supabase project at https://supabase.com
  // and replace these placeholder values with your project's credentials
  static const String supabaseUrl = 'https://your-project-url.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // Supabase table names
  static const String usersTable = 'users';
  static const String gamesTable = 'games';
  static const String playersTable = 'players';
  static const String gamePlayersTable = 'game_players';
  static const String gameTransactionsTable = 'game_transactions';
}
