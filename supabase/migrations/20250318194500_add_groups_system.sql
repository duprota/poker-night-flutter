-- Criação das tabelas para o sistema de grupos

-- Tabela de grupos
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  avatar_url TEXT,
  is_private BOOLEAN DEFAULT FALSE,
  
  CONSTRAINT name_length CHECK (char_length(name) >= 3 AND char_length(name) <= 50)
);

-- Tabela de membros do grupo
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(group_id, user_id)
);

-- Tabela de convites para grupo
CREATE TABLE IF NOT EXISTS group_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  
  UNIQUE(group_id, invitee_id, status) WHERE status = 'pending'
);

-- Tabela de atividades do grupo
CREATE TABLE IF NOT EXISTS group_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  type TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);

-- Políticas de segurança RLS (Row Level Security)

-- Habilitar RLS para todas as tabelas
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_activities ENABLE ROW LEVEL SECURITY;

-- Políticas para a tabela groups
CREATE POLICY "Grupos públicos visíveis para todos os usuários autenticados"
  ON groups FOR SELECT
  USING (auth.role() = 'authenticated' AND NOT is_private);

CREATE POLICY "Grupos privados visíveis apenas para membros"
  ON groups FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    is_private AND
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = groups.id
      AND group_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Apenas o proprietário pode atualizar o grupo"
  ON groups FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    owner_id = auth.uid()
  );

CREATE POLICY "Apenas o proprietário pode excluir o grupo"
  ON groups FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    owner_id = auth.uid()
  );

CREATE POLICY "Usuários autenticados podem criar grupos"
  ON groups FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    owner_id = auth.uid()
  );

-- Políticas para a tabela group_members
CREATE POLICY "Membros visíveis para outros membros do grupo"
  ON group_members FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Administradores e proprietários podem adicionar membros"
  ON group_members FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role IN ('owner', 'admin')
    )
  );

CREATE POLICY "Administradores e proprietários podem atualizar membros"
  ON group_members FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role IN ('owner', 'admin')
    )
  );

CREATE POLICY "Administradores e proprietários podem remover membros"
  ON group_members FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    (
      -- Administradores e proprietários podem remover outros membros
      EXISTS (
        SELECT 1 FROM group_members AS gm
        WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role IN ('owner', 'admin')
      )
      OR
      -- Qualquer membro pode remover a si mesmo
      group_members.user_id = auth.uid()
    )
  );

-- Políticas para a tabela group_invitations
CREATE POLICY "Convites visíveis para o convidado"
  ON group_invitations FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    (
      invitee_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM group_members AS gm
        WHERE gm.group_id = group_invitations.group_id
        AND gm.user_id = auth.uid()
        AND gm.role IN ('owner', 'admin')
      )
    )
  );

CREATE POLICY "Administradores e proprietários podem criar convites"
  ON group_invitations FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_invitations.group_id
      AND gm.user_id = auth.uid()
      AND gm.role IN ('owner', 'admin')
    )
  );

CREATE POLICY "Convidados podem atualizar seus próprios convites"
  ON group_invitations FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    invitee_id = auth.uid()
  );

CREATE POLICY "Administradores e proprietários podem excluir convites"
  ON group_invitations FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_invitations.group_id
      AND gm.user_id = auth.uid()
      AND gm.role IN ('owner', 'admin')
    )
  );

-- Políticas para a tabela group_activities
CREATE POLICY "Atividades visíveis para membros do grupo"
  ON group_activities FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_activities.group_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Membros podem registrar atividades"
  ON group_activities FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM group_members AS gm
      WHERE gm.group_id = group_activities.group_id
      AND gm.user_id = auth.uid()
    )
  );

-- Função para atualizar o timestamp de última atividade do membro
CREATE OR REPLACE FUNCTION update_group_member_last_active()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE group_members
  SET last_active = NOW()
  WHERE group_id = NEW.group_id AND user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para atualizar o timestamp de última atividade do membro
CREATE TRIGGER update_member_last_active
AFTER INSERT ON group_activities
FOR EACH ROW
EXECUTE FUNCTION update_group_member_last_active();

-- Função para expirar convites antigos
CREATE OR REPLACE FUNCTION expire_old_invitations()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE group_invitations
  SET status = 'expired'
  WHERE status = 'pending' AND expires_at < NOW();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para expirar convites antigos (executado diariamente)
CREATE TRIGGER expire_old_invitations_trigger
AFTER INSERT ON group_invitations
EXECUTE FUNCTION expire_old_invitations();
