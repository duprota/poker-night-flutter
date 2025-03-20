-- Desabilitar completamente RLS para group_members
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas existentes para group_members
DROP POLICY IF EXISTS "Usuários autenticados podem ver membros" ON group_members;
DROP POLICY IF EXISTS "Usuários autenticados podem adicionar membros" ON group_members;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar membros" ON group_members;
DROP POLICY IF EXISTS "Usuários autenticados podem remover membros" ON group_members;
