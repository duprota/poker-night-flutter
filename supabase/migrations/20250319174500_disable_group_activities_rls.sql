-- Desabilitar temporariamente RLS para group_activities
ALTER TABLE group_activities DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas existentes para group_activities
DROP POLICY IF EXISTS "Atividades visíveis para membros do grupo" ON group_activities;
