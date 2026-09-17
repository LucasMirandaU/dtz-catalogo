-- =========================================================================
-- SCRIPT 06: Actualización del Módulo de Taller (v1.1.0)
-- Descripción: Agrega nuevas opciones al checklist de estado inicial.
-- =========================================================================

ALTER TABLE public.reparaciones 
ADD COLUMN IF NOT EXISTS chk_sin_bandeja BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_tapa_rota BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_camaras_ok BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_pin_carga_ok BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_parlantes_ok BOOLEAN DEFAULT false;
