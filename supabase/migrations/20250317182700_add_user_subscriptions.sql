-- Create user_subscriptions table
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'free' CHECK (status IN ('free', 'premium', 'pro')),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy for users to read their own subscription
CREATE POLICY "Users can read their own subscription" ON user_subscriptions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy for users to update their own subscription (will be controlled by backend functions)
CREATE POLICY "Users can update their own subscription" ON user_subscriptions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_user_subscriptions_updated_at
BEFORE UPDATE ON user_subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
