-- ========================================================================================
-- Agregar campo de firma digital de retiro a reparaciones
-- Ejecutar en Supabase -> SQL Editor -> New Query
-- ========================================================================================

ALTER TABLE public.reparaciones ADD COLUMN IF NOT EXISTS firma_retiro text;
