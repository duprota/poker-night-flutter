/// Constants for Supabase configuration
class SupabaseConstants {
  // Private constructor to prevent instantiation
  SupabaseConstants._();

  // TODO: Replace with your actual Supabase URL and anon key
  // You'll need to create a Supabase project at https://supabase.com
  // and replace these placeholder values with your project's credentials
  static const String supabaseUrl = 'https://qyfyyajgeytwldpqvtzd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5Znl5YWpnZXl0d2xkcHF2dHpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4OTQ3OTUsImV4cCI6MjA1NzQ3MDc5NX0.JDBPY72xqzxFPMhvYAJ5wpt-2yN10vj3uDpUobOd8l8';

  // Supabase table names
  static const String usersTable = 'users';
  static const String gamesTable = 'games';
  static const String playersTable = 'players';
  static const String gamePlayersTable = 'game_players';
  static const String gameTransactionsTable = 'game_transactions';
}
