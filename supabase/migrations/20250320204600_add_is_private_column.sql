-- Adicionar coluna is_private à tabela groups
ALTER TABLE groups ADD COLUMN IF NOT EXISTS is_private BOOLEAN NOT NULL DEFAULT false;
