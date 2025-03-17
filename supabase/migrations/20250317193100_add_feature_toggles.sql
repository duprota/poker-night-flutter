-- Create feature_toggles table
CREATE TABLE IF NOT EXISTS feature_toggles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feature TEXT NOT NULL UNIQUE,
  enabled BOOLEAN NOT NULL DEFAULT true,
  subscription_level TEXT NOT NULL DEFAULT 'free' CHECK (subscription_level IN ('free', 'premium', 'pro', 'all')),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE feature_toggles ENABLE ROW LEVEL SECURITY;

-- Policy for users to read feature toggles
CREATE POLICY "Users can read feature toggles" ON feature_toggles
  FOR SELECT
  USING (true);

-- Only allow admins to update feature toggles (will be managed through Supabase dashboard)
CREATE POLICY "Only admins can update feature toggles" ON feature_toggles
  FOR UPDATE
  USING (auth.uid() IN (SELECT id FROM auth.users WHERE auth.email() IN ('admin@example.com')));

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_feature_toggles_updated_at
BEFORE UPDATE ON feature_toggles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Insert default feature toggles
INSERT INTO feature_toggles (feature, enabled, subscription_level, description)
VALUES
  ('createGame', true, 'free', 'Ability to create a new game'),
  ('joinGame', true, 'free', 'Ability to join an existing game'),
  ('unlimitedPlayers', true, 'premium', 'Allow unlimited players in a game'),
  ('statistics', true, 'pro', 'Access to advanced statistics'),
  ('exportData', true, 'premium', 'Export game data'),
  ('darkMode', true, 'all', 'Dark mode theme'),
  ('notifications', true, 'free', 'Push notifications'),
  ('chatInGame', false, 'premium', 'Chat during games'),
  ('tournaments', false, 'pro', 'Tournament functionality'),
  ('leaderboards', true, 'free', 'Player rankings and leaderboards');
