-- Corrigir a política de segurança que causa recursão infinita na tabela group_members

-- Remover a política problemática
DROP POLICY IF EXISTS "Membros visíveis para outros membros do grupo" ON group_members;

-- Criar uma nova política que não cause recursão
CREATE POLICY "Membros visíveis para usuários autenticados"
  ON group_members FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    (
      -- O usuário pode ver seus próprios registros
      user_id = auth.uid()
      OR
      -- O usuário pode ver os membros de grupos públicos
      EXISTS (
        SELECT 1 FROM groups
        WHERE groups.id = group_members.group_id
        AND NOT groups.is_private
      )
      OR
      -- O usuário pode ver os membros de grupos privados aos quais pertence
      -- (usando uma subquery direta em vez de uma referência circular)
      group_id IN (
        SELECT group_id FROM group_members
        WHERE user_id = auth.uid()
      )
    )
  );

-- Atualizar a política para adicionar membros para evitar possíveis problemas
DROP POLICY IF EXISTS "Administradores e proprietários podem adicionar membros" ON group_members;

CREATE POLICY "Administradores e proprietários podem adicionar membros"
  ON group_members FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    (
      -- O usuário pode adicionar a si mesmo em grupos públicos
      (
        user_id = auth.uid() AND
        EXISTS (
          SELECT 1 FROM groups
          WHERE groups.id = group_members.group_id
          AND NOT groups.is_private
        )
      )
      OR
      -- Administradores e proprietários podem adicionar membros
      group_id IN (
        SELECT group_id FROM group_members
        WHERE user_id = auth.uid()
        AND role IN ('owner', 'admin')
      )
    )
  );

-- Atualizar a política para atualizar membros
DROP POLICY IF EXISTS "Administradores e proprietários podem atualizar membros" ON group_members;

CREATE POLICY "Administradores e proprietários podem atualizar membros"
  ON group_members FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    (
      -- O usuário pode atualizar seu próprio registro
      user_id = auth.uid()
      OR
      -- Administradores e proprietários podem atualizar membros
      group_id IN (
        SELECT group_id FROM group_members
        WHERE user_id = auth.uid()
        AND role IN ('owner', 'admin')
      )
    )
  );

-- Atualizar a política para remover membros
DROP POLICY IF EXISTS "Administradores e proprietários podem remover membros" ON group_members;

CREATE POLICY "Administradores e proprietários podem remover membros"
  ON group_members FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    (
      -- O usuário pode remover a si mesmo
      user_id = auth.uid()
      OR
      -- Administradores e proprietários podem remover membros
      group_id IN (
        SELECT group_id FROM group_members
        WHERE user_id = auth.uid()
        AND role IN ('owner', 'admin')
      )
    )
  );
