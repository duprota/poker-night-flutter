-- Verificar se o tipo enum existe e corrigir ou criar
DO $$
BEGIN
    -- Verificar se o tipo group_member_role existe
    IF EXISTS (
        SELECT 1 FROM pg_type 
        JOIN pg_namespace ON pg_namespace.oid = pg_type.typnamespace
        WHERE typname = 'group_member_role' AND nspname = 'public'
    ) THEN
        -- Alterar o enum existente adicionando o valor 'owner' se não existir
        BEGIN
            ALTER TYPE group_member_role ADD VALUE 'owner';
        EXCEPTION
            WHEN duplicate_object THEN
                -- 'owner' já existe no enum
                NULL;
        END;
    ELSE
        -- Se o enum não existir, vamos atualizar a coluna para usar TEXT novamente
        -- com a restrição CHECK apropriada
        ALTER TABLE group_members 
        ALTER COLUMN role TYPE TEXT,
        ADD CONSTRAINT group_members_role_check 
        CHECK (role IN ('owner', 'admin', 'member'));
    END IF;
END
$$;
