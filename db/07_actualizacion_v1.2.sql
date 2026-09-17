-- =========================================================================
-- Script SQL de Actualización a v1.2.0 (ImgBB + Mejoras Taller/Catálogo)
-- Ejecutar en Supabase -> SQL Editor -> New Query
-- =========================================================================

-- 1. Añadir columna 'oculto' a la tabla product_overrides
-- Permite ocultar productos en la web pública sin que se borre al reimportar el Excel.
ALTER TABLE public.product_overrides 
ADD COLUMN IF NOT EXISTS oculto boolean DEFAULT false;

-- 2. Añadir columna 'fotos' a la tabla reparaciones
-- Almacena un array JSONB con las URLs públicas de ImgBB (máximo 3 fotos por orden).
ALTER TABLE public.reparaciones 
ADD COLUMN IF NOT EXISTS fotos jsonb DEFAULT '[]'::jsonb;

-- NOTA: No es necesario modificar las políticas RLS, ya que las políticas existentes
-- para product_overrides y reparaciones cubren automáticamente las nuevas columnas.
