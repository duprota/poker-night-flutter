-- Adicionar coluna owner_id à tabela groups
ALTER TABLE groups ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id);
