-- Modificar a coluna created_by para permitir valores nulos
ALTER TABLE groups ALTER COLUMN created_by DROP NOT NULL;
