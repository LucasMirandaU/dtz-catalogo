-- ========================================================================================
-- Script Corrector de Recursión (Hotfix)
-- Ejecutar en Supabase -> SQL Editor
-- ========================================================================================

-- 1. Eliminar la política que está causando el bucle infinito
DROP POLICY IF EXISTS "Optimized read all profiles" ON public.profiles;

-- 2. Restaurar lectura segura sin recursividad
-- Permitir que cada usuario lea su propio perfil sin problemas
-- Para que el panel de "Usuarios" funcione para los admins sin causar bucles,
-- habilitamos la lectura general de perfiles (solo expone email y rol internamente).
-- La seguridad de las tablas sensibles (reparaciones y pedidos) sigue intacta.
CREATE POLICY "Optimized read all profiles" ON public.profiles
  FOR SELECT TO authenticated 
  USING (true);
