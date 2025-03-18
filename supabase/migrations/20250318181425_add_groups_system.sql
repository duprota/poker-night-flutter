
-- Create enum for group member roles
CREATE TYPE group_member_role AS ENUM ('admin', 'dealer', 'player');

-- Create enum for invitation status
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');

-- Create enum for activity types
CREATE TYPE group_activity_type AS ENUM (
  'group_created',
  'member_added',
  'member_removed',
  'role_changed',
  'game_created',
  'game_updated',
  'game_deleted',
  'invitation_sent',
  'invitation_accepted'
);

-- Create groups table
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  max_players INT NOT NULL DEFAULT 8,
  is_public BOOLEAN NOT NULL DEFAULT false,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create group_members table
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role group_member_role NOT NULL DEFAULT 'player',
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- Create group_invitations table
CREATE TABLE IF NOT EXISTS group_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  token TEXT NOT NULL UNIQUE,
  role group_member_role NOT NULL DEFAULT 'player',
  status invitation_status NOT NULL DEFAULT 'pending',
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (NOW() + interval '7 days'),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create group_activities table
CREATE TABLE IF NOT EXISTS group_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  activity_type group_activity_type NOT NULL,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Alter games table to add group relation
ALTER TABLE games ADD COLUMN IF NOT EXISTS group_id UUID REFERENCES groups(id) ON DELETE SET NULL;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_groups_created_by ON groups(created_by);
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_group_invitations_group_id ON group_invitations(group_id);
CREATE INDEX IF NOT EXISTS idx_group_invitations_token ON group_invitations(token);
CREATE INDEX IF NOT EXISTS idx_group_activities_group_id ON group_activities(group_id);
CREATE INDEX IF NOT EXISTS idx_games_group_id ON games(group_id);

-- Add RLS policies
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_activities ENABLE ROW LEVEL SECURITY;

-- Policies for groups table
CREATE POLICY "Users can view groups they are members of" ON groups
  FOR SELECT
  USING (
    id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
    OR is_public = true
  );

CREATE POLICY "Users can create groups" ON groups
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group admins can update their groups" ON groups
  FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can delete their groups" ON groups
  FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = id AND role = 'admin'
    )
  );

-- Policies for group_members table
CREATE POLICY "Users can view group members" ON group_members
  FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Group admins can insert members" ON group_members
  FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_members.group_id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can update members" ON group_members
  FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_members.group_id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can delete members" ON group_members
  FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_members.group_id AND role = 'admin'
    )
  );

-- Policies for group_invitations table
CREATE POLICY "Users can view invitations for groups they are admins of" ON group_invitations
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_invitations.group_id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can create invitations" ON group_invitations
  FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_invitations.group_id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can update invitations" ON group_invitations
  FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_invitations.group_id AND role = 'admin'
    )
  );

CREATE POLICY "Group admins can delete invitations" ON group_invitations
  FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_invitations.group_id AND role = 'admin'
    )
  );

-- Policies for group_activities table
CREATE POLICY "Users can view activities for groups they are members of" ON group_activities
  FOR SELECT
  USING (
    group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- Function for automatically adding creator as admin when a group is created
CREATE OR REPLACE FUNCTION add_group_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (NEW.id, NEW.created_by, 'admin');

  -- Log the activity
  INSERT INTO group_activities (group_id, user_id, activity_type, details)
  VALUES (NEW.id, NEW.created_by, 'group_created', json_build_object('group_name', NEW.name));

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatically adding creator as admin
CREATE TRIGGER add_group_creator_as_admin_trigger
AFTER INSERT ON groups
FOR EACH ROW
EXECUTE FUNCTION add_group_creator_as_admin();

-- Function to update updated_at on groups table
CREATE OR REPLACE FUNCTION update_groups_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating updated_at on groups
CREATE TRIGGER update_groups_updated_at_trigger
BEFORE UPDATE ON groups
FOR EACH ROW
EXECUTE FUNCTION update_groups_updated_at();

-- Function to update updated_at on group_invitations table
CREATE OR REPLACE FUNCTION update_group_invitations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating updated_at on group_invitations
CREATE TRIGGER update_group_invitations_updated_at_trigger
BEFORE UPDATE ON group_invitations
FOR EACH ROW
EXECUTE FUNCTION update_group_invitations_updated_at();

-- Function to log member added activity
CREATE OR REPLACE FUNCTION log_member_added()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_activities (group_id, user_id, activity_type, details)
  VALUES (NEW.group_id, auth.uid(), 'member_added', json_build_object('user_id', NEW.user_id, 'role', NEW.role));
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to log member added
CREATE TRIGGER log_member_added_trigger
AFTER INSERT ON group_members
FOR EACH ROW
EXECUTE FUNCTION log_member_added();

-- Function to log member role changed
CREATE OR REPLACE FUNCTION log_member_role_changed()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.role != NEW.role THEN
    INSERT INTO group_activities (group_id, user_id, activity_type, details)
    VALUES (NEW.group_id, auth.uid(), 'role_changed', json_build_object('user_id', NEW.user_id, 'old_role', OLD.role, 'new_role', NEW.role));
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to log member role changed
CREATE TRIGGER log_member_role_changed_trigger
AFTER UPDATE ON group_members
FOR EACH ROW
EXECUTE FUNCTION log_member_role_changed();

-- Function to log member removed
CREATE OR REPLACE FUNCTION log_member_removed()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO group_activities (group_id, user_id, activity_type, details)
  VALUES (OLD.group_id, auth.uid(), 'member_removed', json_build_object('user_id', OLD.user_id, 'role', OLD.role));
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to log member removed
CREATE TRIGGER log_member_removed_trigger
AFTER DELETE ON group_members
FOR EACH ROW
EXECUTE FUNCTION log_member_removed();