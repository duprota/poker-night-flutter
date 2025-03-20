-- Garantir que todas as colunas necessárias existam na tabela groups
ALTER TABLE groups ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE groups ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS avatar_url TEXT;
-- is_private já foi adicionado em uma migração anterior
