-- Modificar coluna created_by para permitir valores nulos
ALTER TABLE groups ALTER COLUMN created_by DROP NOT NULL;

-- Definir valor padrão para a coluna created_by
ALTER TABLE groups ALTER COLUMN created_by SET DEFAULT auth.uid();
