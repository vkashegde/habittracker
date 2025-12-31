/// Supabase configuration shared across all apps.
///
/// Values are read from compile-time environment (dart-define) so that secrets
/// aren't checked into source control.
///
/// Example:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
