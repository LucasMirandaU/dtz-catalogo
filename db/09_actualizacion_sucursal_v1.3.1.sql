-- =========================================================================
-- Actualización v1.3.1: Sucursal de Ingreso en Reparaciones
-- Ejecutar en Supabase -> SQL Editor -> New Query
-- =========================================================================

ALTER TABLE IF EXISTS public.reparaciones 
ADD COLUMN IF NOT EXISTS sucursal text DEFAULT 'Local 2984';
