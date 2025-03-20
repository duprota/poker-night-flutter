-- Adicionar um valor padrão para a coluna created_by
ALTER TABLE groups ALTER COLUMN created_by SET DEFAULT auth.uid();
