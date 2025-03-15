-- Migration: Adicionar campo phone à tabela users
ALTER TABLE users
ADD COLUMN phone VARCHAR(15);

-- Adicionar índice para o campo phone
CREATE INDEX idx_users_phone ON users(phone);