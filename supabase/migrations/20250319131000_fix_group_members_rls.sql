-- Desabilitar temporariamente RLS para group_members
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;

-- Recriar as políticas com uma abordagem mais simples
DROP POLICY IF EXISTS "Membros visíveis para outros membros do grupo" ON group_members;
DROP POLICY IF EXISTS "Administradores e proprietários podem adicionar membros" ON group_members;
DROP POLICY IF EXISTS "Administradores e proprietários podem atualizar membros" ON group_members;
DROP POLICY IF EXISTS "Administradores e proprietários podem remover membros" ON group_members;

-- Reativar RLS com as políticas corrigidas
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Política simples para visualizar membros (sem recursão)
CREATE POLICY "Usuários autenticados podem ver membros"
  ON group_members FOR SELECT
  USING (auth.role() = 'authenticated');

-- Política para inserir membros
CREATE POLICY "Usuários autenticados podem adicionar membros"
  ON group_members FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Política para atualizar membros
CREATE POLICY "Usuários autenticados podem atualizar membros"
  ON group_members FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Política para remover membros
CREATE POLICY "Usuários autenticados podem remover membros"
  ON group_members FOR DELETE
  USING (auth.role() = 'authenticated');
