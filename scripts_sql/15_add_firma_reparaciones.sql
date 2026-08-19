-- ========================================================================================
-- Agregar campo de firma digital a reparaciones
-- Ejecutar en Supabase -> SQL Editor
-- ========================================================================================

ALTER TABLE public.reparaciones ADD COLUMN IF NOT EXISTS firma_cliente text;
