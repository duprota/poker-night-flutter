-- Desabilitar temporariamente RLS nas tabelas do sistema de grupos
-- para resolver problemas de permissão e recursão infinita

-- Remover políticas existentes da tabela groups
DROP POLICY IF EXISTS "Users can view groups they are members of" ON groups;
DROP POLICY IF EXISTS "Users can create groups" ON groups; 
DROP POLICY IF EXISTS "Group admins can update their groups" ON groups;
DROP POLICY IF EXISTS "Group admins can delete their groups" ON groups;

-- Remover políticas existentes da tabela group_members
DROP POLICY IF EXISTS "Users can view members of their groups" ON group_members;
DROP POLICY IF EXISTS "Group admins can add members" ON group_members;
DROP POLICY IF EXISTS "Group admins can update members" ON group_members;
DROP POLICY IF EXISTS "Group admins can delete members" ON group_members;

-- Remover políticas existentes da tabela group_activities
DROP POLICY IF EXISTS "Users can view activities of their groups" ON group_activities;
DROP POLICY IF EXISTS "Users can create activities for their groups" ON group_activities;

-- Desabilitar RLS temporariamente
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE group_activities DISABLE ROW LEVEL SECURITY;

-- Criar política simples para garantir acesso a usuários autenticados
CREATE POLICY "Authenticated users can access groups" ON groups FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can access group members" ON group_members FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can access group activities" ON group_activities FOR ALL USING (auth.role() = 'authenticated');
