import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/constants/supabase_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  
  final client = Supabase.instance.client;
  
  try {
    print('Iniciando correção da política de segurança...');
    
    // Remover as políticas problemáticas
    final dropPoliciesResult = await client.rpc('execute_sql', params: {
      'sql_query': '''
      DROP POLICY IF EXISTS "Membros visíveis para outros membros do grupo" ON group_members;
      DROP POLICY IF EXISTS "Administradores e proprietários podem adicionar membros" ON group_members;
      DROP POLICY IF EXISTS "Administradores e proprietários podem atualizar membros" ON group_members;
      DROP POLICY IF EXISTS "Administradores e proprietários podem remover membros" ON group_members;
      '''
    });
    
    print('Políticas antigas removidas: $dropPoliciesResult');
    
    // Criar as novas políticas
    final createPoliciesResult = await client.rpc('execute_sql', params: {
      'sql_query': '''
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
            group_id IN (
              SELECT group_id FROM group_members
              WHERE user_id = auth.uid()
            )
          )
        );

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
      '''
    });
    
    print('Novas políticas criadas: $createPoliciesResult');
    print('Correção concluída com sucesso!');
  } catch (e) {
    print('Erro ao corrigir a política: $e');
  }
}
