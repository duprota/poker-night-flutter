-- Desabilitar temporariamente RLS para groups
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas existentes para groups
DROP POLICY IF EXISTS "Users can view groups they are members of" ON groups;
DROP POLICY IF EXISTS "Group admins can delete their groups" ON groups;
DROP POLICY IF EXISTS "Group admins can update their groups" ON groups;
DROP POLICY IF EXISTS "Users can create groups" ON groups;
