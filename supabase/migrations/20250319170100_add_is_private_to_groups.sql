-- Adicionar coluna is_private à tabela groups
ALTER TABLE groups ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT false;

-- Atualizar as políticas existentes para a tabela groups
DROP POLICY IF EXISTS "Users can view groups they are members of" ON groups;

-- Recriar a política para visualização de grupos
CREATE POLICY "Users can view groups they are members of"
  ON groups FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    (
      -- Grupos públicos são visíveis para todos
      NOT is_private
      OR
      -- Grupos privados são visíveis apenas para membros
      EXISTS (
        SELECT 1 FROM group_members
        WHERE group_members.group_id = groups.id
        AND group_members.user_id = auth.uid()
      )
    )
  );
